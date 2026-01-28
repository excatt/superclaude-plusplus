# Responsive Design Skill

반응형 디자인 가이드를 실행합니다.

## 브레이크포인트

### 일반적인 브레이크포인트
```css
/* Mobile First */
/* 기본: 모바일 */

/* Tablet */
@media (min-width: 640px) { }

/* Small Desktop */
@media (min-width: 768px) { }

/* Desktop */
@media (min-width: 1024px) { }

/* Large Desktop */
@media (min-width: 1280px) { }

/* Extra Large */
@media (min-width: 1536px) { }
```

### Tailwind CSS 기본값
```
sm:  640px
md:  768px
lg:  1024px
xl:  1280px
2xl: 1536px
```

## CSS 기법

### Fluid Typography
```css
/* clamp(min, preferred, max) */
h1 {
  font-size: clamp(1.5rem, 4vw, 3rem);
}

p {
  font-size: clamp(1rem, 2vw + 0.5rem, 1.25rem);
}
```

### Fluid Spacing
```css
.container {
  padding: clamp(1rem, 5vw, 3rem);
  gap: clamp(1rem, 3vw, 2rem);
}
```

### Container Queries
```css
.card-container {
  container-type: inline-size;
}

@container (min-width: 400px) {
  .card {
    display: flex;
    flex-direction: row;
  }
}
```

## Flexbox 레이아웃

### 기본 반응형 레이아웃
```css
.container {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}

.item {
  flex: 1 1 300px; /* grow shrink basis */
}
```

### 네비게이션
```css
.nav {
  display: flex;
  flex-direction: column;
}

@media (min-width: 768px) {
  .nav {
    flex-direction: row;
    justify-content: space-between;
  }
}
```

## Grid 레이아웃

### Auto-fit / Auto-fill
```css
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}
```

### 영역 기반 레이아웃
```css
.layout {
  display: grid;
  grid-template-areas:
    "header"
    "main"
    "sidebar"
    "footer";
}

@media (min-width: 768px) {
  .layout {
    grid-template-columns: 1fr 3fr;
    grid-template-areas:
      "header header"
      "sidebar main"
      "footer footer";
  }
}
```

## 이미지

### 반응형 이미지
```html
<img
  src="image.jpg"
  srcset="image-400.jpg 400w,
          image-800.jpg 800w,
          image-1200.jpg 1200w"
  sizes="(max-width: 600px) 100vw,
         (max-width: 1200px) 50vw,
         33vw"
  alt="설명"
>
```

### Picture 요소
```html
<picture>
  <source media="(min-width: 1024px)" srcset="desktop.jpg">
  <source media="(min-width: 640px)" srcset="tablet.jpg">
  <img src="mobile.jpg" alt="설명">
</picture>
```

### CSS 이미지
```css
.hero {
  background-image: url('mobile.jpg');
}

@media (min-width: 768px) {
  .hero {
    background-image: url('desktop.jpg');
  }
}

/* 또는 image-set */
.hero {
  background-image: image-set(
    url('image.webp') type('image/webp'),
    url('image.jpg') type('image/jpeg')
  );
}
```

## Tailwind CSS

### 반응형 유틸리티
```html
<div class="
  flex flex-col
  md:flex-row
  gap-4 md:gap-8
  p-4 md:p-8
">
  <div class="w-full md:w-1/3">Sidebar</div>
  <div class="w-full md:w-2/3">Main</div>
</div>
```

### 숨기기/보이기
```html
<nav class="hidden md:block">Desktop Nav</nav>
<nav class="md:hidden">Mobile Nav</nav>
```

### 그리드
```html
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
  <div>Item 4</div>
</div>
```

## 모바일 고려사항

### 터치 타겟
```css
/* 최소 44x44px */
button, a {
  min-height: 44px;
  min-width: 44px;
  padding: 12px;
}
```

### 뷰포트 메타
```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

### 안전 영역 (노치)
```css
.container {
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
  padding-bottom: env(safe-area-inset-bottom);
}
```

## 테스트

### 디바이스 체크리스트
```
Mobile:
- iPhone SE (375px)
- iPhone 14 (390px)
- Android (360px)

Tablet:
- iPad Mini (768px)
- iPad (820px)
- iPad Pro (1024px)

Desktop:
- Laptop (1366px)
- Desktop (1920px)
- Large (2560px)
```

### Chrome DevTools
```
1. F12 → Device Toolbar
2. 다양한 디바이스 선택
3. 반응형 모드로 크기 조절
4. 네트워크 쓰로틀링 테스트
```

## 체크리스트

### 레이아웃
- [ ] Mobile-first 접근
- [ ] 유연한 그리드
- [ ] 적절한 브레이크포인트
- [ ] 가로 스크롤 없음

### 타이포그래피
- [ ] 읽기 쉬운 폰트 크기
- [ ] 적절한 줄 길이 (45-75자)
- [ ] 유동적 크기 조절

### 이미지/미디어
- [ ] 반응형 이미지
- [ ] 적절한 포맷 (WebP)
- [ ] 지연 로딩

### 터치
- [ ] 터치 타겟 44px+
- [ ] 호버 대안 (터치)
- [ ] 스와이프 제스처

## 출력 형식

```
## Responsive Design

### Breakpoints
```css
/* 브레이크포인트 정의 */
```

### Layout Strategy
- 접근법: Mobile-first
- 그리드: CSS Grid + Flexbox

### Components
| 컴포넌트 | Mobile | Tablet | Desktop |
|---------|--------|--------|---------|
| Nav | 햄버거 | 아이콘 | 전체 |
| Grid | 1열 | 2열 | 4열 |

### Implementation
```css
/* 핵심 CSS */
```
```

---

요청에 맞는 반응형 디자인을 적용하세요.
