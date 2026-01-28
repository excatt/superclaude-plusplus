# Migration Skill

데이터베이스/스키마 마이그레이션을 위한 가이드를 실행합니다.

## 마이그레이션 원칙

### 핵심 규칙
```
1. 항상 롤백 가능하게
2. 작은 단위로 점진적으로
3. 무중단 배포 고려
4. 데이터 손실 방지
5. 테스트 환경에서 먼저
```

### 마이그레이션 순서
```
1. 새 스키마 추가 (additive)
2. 코드 배포 (양쪽 지원)
3. 데이터 마이그레이션
4. 이전 코드 제거
5. 이전 스키마 제거
```

## 스키마 마이그레이션

### 안전한 변경
```sql
-- ✅ 안전: 컬럼 추가 (기본값)
ALTER TABLE users ADD COLUMN status VARCHAR(20) DEFAULT 'active';

-- ✅ 안전: 인덱스 추가 (CONCURRENTLY)
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- ✅ 안전: 새 테이블 생성
CREATE TABLE user_preferences (...);
```

### 위험한 변경 (주의 필요)
```sql
-- ⚠️ 주의: 컬럼 삭제 (데이터 손실)
ALTER TABLE users DROP COLUMN old_field;

-- ⚠️ 주의: 컬럼 타입 변경
ALTER TABLE users ALTER COLUMN age TYPE INTEGER;

-- ⚠️ 주의: NOT NULL 추가
ALTER TABLE users ALTER COLUMN email SET NOT NULL;

-- ⚠️ 주의: 테이블 이름 변경
ALTER TABLE users RENAME TO accounts;
```

### 안전한 컬럼 이름 변경
```
단계:
1. 새 컬럼 추가
2. 데이터 복사 (백그라운드)
3. 코드 업데이트 (양쪽 읽기)
4. 새 컬럼만 사용하도록 코드 변경
5. 이전 컬럼 삭제
```

## 마이그레이션 도구

### Prisma (Node.js)
```bash
# 마이그레이션 생성
npx prisma migrate dev --name add_user_status

# 프로덕션 적용
npx prisma migrate deploy

# 롤백 (수동)
npx prisma migrate resolve --rolled-back add_user_status
```

```prisma
// schema.prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  status    String   @default("active") // 새 필드
  createdAt DateTime @default(now())
}
```

### Alembic (Python)
```bash
# 마이그레이션 생성
alembic revision --autogenerate -m "add_user_status"

# 적용
alembic upgrade head

# 롤백
alembic downgrade -1
```

```python
# migrations/versions/xxx_add_user_status.py
def upgrade():
    op.add_column('users',
        sa.Column('status', sa.String(20), server_default='active')
    )

def downgrade():
    op.drop_column('users', 'status')
```

### Knex (Node.js)
```bash
# 마이그레이션 생성
npx knex migrate:make add_user_status

# 적용
npx knex migrate:latest

# 롤백
npx knex migrate:rollback
```

```javascript
// migrations/xxx_add_user_status.js
exports.up = function(knex) {
  return knex.schema.alterTable('users', (table) => {
    table.string('status', 20).defaultTo('active');
  });
};

exports.down = function(knex) {
  return knex.schema.alterTable('users', (table) => {
    table.dropColumn('status');
  });
};
```

## 데이터 마이그레이션

### 배치 처리
```javascript
async function migrateData() {
  const BATCH_SIZE = 1000;
  let offset = 0;

  while (true) {
    const rows = await db.query(`
      SELECT id, old_field
      FROM users
      WHERE new_field IS NULL
      LIMIT ${BATCH_SIZE}
    `);

    if (rows.length === 0) break;

    for (const row of rows) {
      await db.query(`
        UPDATE users
        SET new_field = $1
        WHERE id = $2
      `, [transform(row.old_field), row.id]);
    }

    offset += BATCH_SIZE;
    console.log(`Migrated ${offset} rows`);

    // 부하 방지
    await sleep(100);
  }
}
```

### 검증
```sql
-- 마이그레이션 전후 비교
SELECT
  COUNT(*) as total,
  COUNT(new_field) as migrated,
  COUNT(*) - COUNT(new_field) as remaining
FROM users;

-- 데이터 정합성 검증
SELECT * FROM users
WHERE old_field IS NOT NULL
  AND new_field != expected_transform(old_field);
```

## 무중단 마이그레이션

### Expand-Contract 패턴
```
Phase 1: Expand (확장)
┌─────────┐     ┌─────────┐
│old_field│ +   │new_field│
└─────────┘     └─────────┘
코드: 양쪽 모두 쓰기, old에서 읽기

Phase 2: Migrate (이전)
데이터를 old → new로 복사

Phase 3: Contract (축소)
코드: new에서만 읽기/쓰기
old_field 삭제
```

### 예시: 컬럼 이름 변경
```sql
-- Phase 1: 새 컬럼 추가
ALTER TABLE users ADD COLUMN full_name VARCHAR(100);

-- Phase 2: 데이터 복사
UPDATE users SET full_name = name WHERE full_name IS NULL;

-- 트리거로 동기화 (선택)
CREATE TRIGGER sync_name
BEFORE INSERT OR UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION sync_name_fields();

-- Phase 3: 이전 컬럼 제거 (코드 배포 후)
ALTER TABLE users DROP COLUMN name;
```

## 체크리스트

### 마이그레이션 전
- [ ] 백업 확인
- [ ] 롤백 계획 수립
- [ ] 테스트 환경 검증
- [ ] 예상 실행 시간 측정
- [ ] 다운타임 공지 (필요시)

### 마이그레이션 중
- [ ] 모니터링 (CPU, 락, 쿼리)
- [ ] 진행 상황 로깅
- [ ] 에러 발생 시 중단 조건

### 마이그레이션 후
- [ ] 데이터 정합성 검증
- [ ] 애플리케이션 정상 동작
- [ ] 성능 확인
- [ ] 롤백 가능 상태 유지 (일정 기간)

## 출력 형식

```
## Migration Plan

### Overview
[마이그레이션 목표 및 영향 범위]

### Risk Assessment
| 위험 | 영향 | 대응 |
|------|------|------|
| 데이터 손실 | High | 백업 확인 |

### Steps
1. [단계 1] - 예상 시간: 5분
2. [단계 2] - 예상 시간: 30분

### Migration Scripts
```sql
-- Up
[적용 스크립트]

-- Down (Rollback)
[롤백 스크립트]
```

### Verification
```sql
-- 검증 쿼리
```

### Rollback Plan
[롤백 절차]
```

---

요청에 맞는 마이그레이션 계획을 수립하세요.
