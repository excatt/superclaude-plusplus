# SEO Skill

SEO 최적화 가이드를 실행합니다.

## 기본 메타 태그

### 필수 태그
```html
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>페이지 제목 | 사이트명</title>
  <meta name="description" content="155자 이내의 페이지 설명">
  <link rel="canonical" href="https://example.com/page">
</head>
```

### Open Graph (소셜 미디어)
```html
<meta property="og:title" content="페이지 제목">
<meta property="og:description" content="페이지 설명">
<meta property="og:image" content="https://example.com/image.jpg">
<meta property="og:url" content="https://example.com/page">
<meta property="og:type" content="website">
<meta property="og:site_name" content="사이트명">
```

### Twitter Card
```html
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="페이지 제목">
<meta name="twitter:description" content="페이지 설명">
<meta name="twitter:image" content="https://example.com/image.jpg">
<meta name="twitter:site" content="@username">
```

## Next.js SEO

### Metadata API
```typescript
// app/page.tsx
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: '홈 | 사이트명',
  description: '사이트 설명',
  openGraph: {
    title: '홈',
    description: '사이트 설명',
    images: ['/og-image.jpg'],
  },
};

// 동적 메타데이터
export async function generateMetadata({ params }): Promise<Metadata> {
  const product = await getProduct(params.id);

  return {
    title: product.name,
    description: product.description,
    openGraph: {
      images: [product.image],
    },
  };
}
```

### 기본 레이아웃
```typescript
// app/layout.tsx
export const metadata: Metadata = {
  metadataBase: new URL('https://example.com'),
  title: {
    default: '사이트명',
    template: '%s | 사이트명',
  },
  description: '기본 설명',
  robots: {
    index: true,
    follow: true,
  },
  alternates: {
    canonical: '/',
    languages: {
      'ko-KR': '/ko',
      'en-US': '/en',
    },
  },
};
```

## 구조화된 데이터 (Schema.org)

### JSON-LD
```typescript
// components/JsonLd.tsx
export function JsonLd({ data }) {
  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  );
}

// 사용
<JsonLd data={{
  '@context': 'https://schema.org',
  '@type': 'Product',
  name: '상품명',
  description: '상품 설명',
  image: 'https://example.com/image.jpg',
  offers: {
    '@type': 'Offer',
    price: '29000',
    priceCurrency: 'KRW',
    availability: 'https://schema.org/InStock',
  },
}} />
```

### 스키마 유형
```javascript
// 조직
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "회사명",
  "url": "https://example.com",
  "logo": "https://example.com/logo.png"
}

// 기사
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "기사 제목",
  "author": { "@type": "Person", "name": "작성자" },
  "datePublished": "2024-01-15"
}

// FAQ
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [{
    "@type": "Question",
    "name": "질문?",
    "acceptedAnswer": {
      "@type": "Answer",
      "text": "답변"
    }
  }]
}

// 빵부스러기
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [{
    "@type": "ListItem",
    "position": 1,
    "name": "홈",
    "item": "https://example.com"
  }]
}
```

## 사이트맵

### sitemap.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://example.com/</loc>
    <lastmod>2024-01-15</lastmod>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://example.com/about</loc>
    <lastmod>2024-01-10</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.8</priority>
  </url>
</urlset>
```

### Next.js 동적 사이트맵
```typescript
// app/sitemap.ts
import { MetadataRoute } from 'next';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const products = await getProducts();

  const productUrls = products.map((product) => ({
    url: `https://example.com/products/${product.slug}`,
    lastModified: product.updatedAt,
    changeFrequency: 'weekly' as const,
    priority: 0.8,
  }));

  return [
    {
      url: 'https://example.com',
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 1,
    },
    ...productUrls,
  ];
}
```

## robots.txt

```txt
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /api/
Disallow: /private/

Sitemap: https://example.com/sitemap.xml
```

```typescript
// app/robots.ts (Next.js)
import { MetadataRoute } from 'next';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: '*',
      allow: '/',
      disallow: ['/admin/', '/api/', '/private/'],
    },
    sitemap: 'https://example.com/sitemap.xml',
  };
}
```

## 성능 최적화 (Core Web Vitals)

### LCP (Largest Contentful Paint)
```html
<!-- 중요 이미지 미리 로드 -->
<link rel="preload" as="image" href="/hero.jpg">

<!-- 이미지 최적화 -->
<img
  src="/hero.jpg"
  srcset="/hero-400.jpg 400w, /hero-800.jpg 800w"
  sizes="(max-width: 600px) 400px, 800px"
  loading="eager"
  fetchpriority="high"
>
```

### CLS (Cumulative Layout Shift)
```css
/* 이미지에 크기 지정 */
img {
  width: 100%;
  height: auto;
  aspect-ratio: 16 / 9;
}

/* 폰트 로딩 최적화 */
@font-face {
  font-family: 'MyFont';
  font-display: swap;
}
```

### FID/INP (Interaction)
```javascript
// 긴 작업 분할
function processLargeArray(items) {
  const chunk = items.splice(0, 100);
  processChunk(chunk);

  if (items.length > 0) {
    requestIdleCallback(() => processLargeArray(items));
  }
}
```

## 체크리스트

### 기본
- [ ] 고유한 title 태그
- [ ] meta description
- [ ] canonical URL
- [ ] Open Graph 태그
- [ ] 구조화된 데이터

### 기술
- [ ] sitemap.xml
- [ ] robots.txt
- [ ] HTTPS
- [ ] 모바일 친화적
- [ ] 빠른 로딩 속도

### 콘텐츠
- [ ] 시맨틱 HTML (h1, h2, ...)
- [ ] 이미지 alt 텍스트
- [ ] 내부 링크
- [ ] 고품질 콘텐츠

## 출력 형식

```
## SEO Optimization

### Meta Tags
```html
<head>...</head>
```

### Structured Data
```json
{ "@context": "https://schema.org", ... }
```

### Sitemap
- 동적 생성: [Yes/No]
- 페이지 수: N개

### Performance
- LCP: < 2.5s
- CLS: < 0.1
- FID: < 100ms

### Checklist
- [x] Meta tags
- [x] Open Graph
- [ ] Structured data
```

---

요청에 맞는 SEO 최적화를 적용하세요.
