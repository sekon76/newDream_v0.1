# 조황일지 - 낚시 종합 앱 백엔드

낚시 종합 앱 **조황일지**의 Spring Boot 백엔드 서버.

---

## 기술 스택

| 항목 | 버전/값 |
|------|---------|
| Java | 17 (Temurin JDK) |
| Spring Boot | 3.3.5 |
| Build | Gradle 8.8 |
| DB | PostgreSQL 16 |
| Cache | Redis |
| 인증 | JWT (HS384) + Redis 블랙리스트 |
| 외부 API | 기상청 단기예보, 해양수산부 조석예보 |

---

## 로컬 실행 방법

### 사전 조건
- PostgreSQL 실행 (`fishingapp` DB, `fishinguser` 계정)
- Redis 실행

### 환경변수 설정 (PowerShell)
```powershell
$env:KMA_API_KEY  = "기상청_API_키"
$env:KHOA_API_KEY = "해양수산부_API_키"
# 선택 (미설정 시 기본값 사용)
$env:JWT_SECRET   = "256비트_이상_시크릿"
$env:DB_PASSWORD  = "DB_비밀번호"
```

### 실행
```powershell
.\gradlew.bat bootRun
```

서버: `http://localhost:8080`

---

## API 엔드포인트

### 회원 (인증 불필요)

| Method | URL | 설명 |
|--------|-----|------|
| POST | `/api/auth/signup` | 회원가입 (`mapProvider`: NAVER \| KAKAO) |
| POST | `/api/auth/login` | 로그인 → `accessToken` 반환 |
| POST | `/api/auth/logout` | 로그아웃 (토큰 즉시 무효화) |

### 낚시 포인트 (Bearer 토큰 필요)

| Method | URL | 설명 |
|--------|-----|------|
| POST | `/api/points` | 낚시 장소 등록 |
| GET | `/api/points` | 내 장소 목록 |
| GET | `/api/points/{id}` | 장소 상세 |
| PUT | `/api/points/{id}` | 장소 수정 |
| DELETE | `/api/points/{id}` | 장소 삭제 |

### 방문기록 · 낚시 일지 (Bearer 토큰 필요)

| Method | URL | 설명 |
|--------|-----|------|
| POST | `/api/points/{id}/visits` | 방문기록 등록 (날씨·조석 자동 수집) |
| GET | `/api/points/{id}/visits` | 방문기록 목록 |
| GET | `/api/points/{id}/visits/{visitId}` | 방문기록 상세 |
| PUT | `/api/points/{id}/visits/{visitId}` | 방문기록 수정 |
| DELETE | `/api/points/{id}/visits/{visitId}` | 방문기록 삭제 |

방문기록에 포함되는 항목:
- 일지 제목 / 본문 / 공개여부
- 조과기록 (어종명 · 마릿수 · 크기cm · 무게g, 복수 등록)
- 채비·미끼 기록
- 날씨 정보 (기온 · 습도 · 풍속 · 풍향 · 파고 · 날씨상태) — 자동 수집
- 조석 정보 (만조/간조 시각 · 높이) — 자동 수집

### 조과 예측 (Bearer 토큰 필요)

| Method | URL | 설명 |
|--------|-----|------|
| GET | `/api/predictions?lat={위도}&lon={경도}&date={날짜}` | 날씨·조석 예보 + 낚시 점수 |

응답 예시:
```json
{
  "date": "2026-07-01",
  "weather": { "condition": "흐림", "temperature": 20.0, "windSpeed": 1.3 },
  "tide": { "highTideTime1": "08:58", "highTideHeight1": 110 },
  "fishingScore": 80,
  "fishingGrade": "매우 좋음"
}
```

낚시 점수 기준 (0~100점):
- 날씨 상태: 맑음 +20, 구름많음 +10, 비 -20
- 기온: 15~25°C +15점
- 풍속: 3m/s 미만 +15점
- 조석 범위: 400cm 이상 차이 +15점

### 커뮤니티 (Bearer 토큰 필요)

| Method | URL | 설명 |
|--------|-----|------|
| GET | `/api/community/posts?page=0&size=20` | 공개 일지 목록 (최신순) |
| GET | `/api/community/posts/{visitId}` | 공개 일지 상세 |

방문기록 등록 시 `isPublic: true`로 설정한 일지가 커뮤니티에 노출됩니다.

---

## 패키지 구조

```
com.fishingapp
├── domain
│   ├── user          # 회원가입/로그인/로그아웃
│   ├── point         # 낚시 포인트 + 방문기록(일지/조과기록/채비)
│   ├── prediction    # 날씨·조석 예측 + 낚시 점수
│   └── community     # 공개 일지 커뮤니티
└── global
    ├── config        # Security, JWT, Redis 설정
    ├── exception     # 공통 예외 처리
    ├── external
    │   ├── kma       # 기상청 단기예보 API 클라이언트
    │   └── khoa      # 해양수산부 조석예보 API 클라이언트
    └── util          # JWT 토큰 유틸
```

---

## 보안

- JWT 로그아웃 시 Redis 블랙리스트로 즉시 토큰 무효화
- 포인트·방문기록 접근 시 소유권 이중 검증 (타인 데이터 접근 차단)
- 인증/인가 실패 시 JSON 에러 응답
- API 키·DB 비밀번호 전부 환경변수로 분리

---

## 개발 현황

- [x] 회원 도메인 (회원가입/로그인/로그아웃)
- [x] 포인트 도메인 (낚시 장소 CRUD + 방문기록 + 일지 + 조과기록)
- [x] 예측 도메인 (기상청·해양수산부 실API 연동)
- [x] 커뮤니티 도메인 (공개 일지 목록/상세)
- [ ] Flutter 앱 개발 (Android-first)
