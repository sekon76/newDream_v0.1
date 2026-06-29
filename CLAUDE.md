# 조황일지 (낚시 종합 앱) - 백엔드 프로젝트

## 프로젝트 개요

낚시 종합 앱 **조황일지**의 Spring Boot 백엔드 서버.
혼자 개발하는 부업 프로젝트 (solo developer).

**핵심 기능 4가지:**
1. 조과 예측 (날씨·조석·수온 기반)
2. 개인 포인트 기록 (낚시 장소 저장)
3. 낚시 일지 작성
4. 커뮤니티 공유

---

## 개발 환경

| 항목 | 버전/값 |
|------|---------|
| Java | 17 (Temurin JDK) |
| Spring Boot | 3.3.5 |
| Build | Gradle 8.8 (Wrapper) |
| DB | PostgreSQL — localhost:5432 |
| Cache | Redis — localhost:6379 |
| Frontend | Flutter 3.44.2 (Android-first, 별도 프로젝트 예정) |

**패키지 매니저**: Scoop (관리자 권한 없음, winget 없음)

---

## DB 접속 정보

```
DB명:     fishingapp
사용자:   fishinguser
비밀번호: fishing1234
포트:     5432
```

---

## GitHub

- **레포**: `git@github.com:sekon76/newDream_v0.1.git`
- **브랜치**: `main`
- **SSH 키**: `~/.ssh/id_ed25519` (ed25519, ringyee@naver.com)

Git 설정:
```
user.name  = sekon76
user.email = ringyee@naver.com
```

---

## JWT 설정 (application.yml)

```
secret:     fishing-app-secret-key-must-be-at-least-256-bits-long-for-hs256
expiration: 86400000  # 24시간(ms)
```

---

## 현재 프로젝트 상태 (2026-06-29 기준)

- [x] 프로젝트 구조 생성 (Gradle, Spring Boot)
- [x] PostgreSQL 설치 및 DB/유저 생성
- [x] Redis 설치 및 실행 확인
- [x] GitHub 연동 완료 (SSH 인증)
- [x] 첫 번째 push 완료
- [x] VS Code 연동
- [x] **global/config** — JWT, Security, Redis 설정 완료 (보안 강화 적용)
- [x] **global/exception** — 공통 예외 처리 (JSON 에러 응답)
- [x] **domain/user** — 회원가입/로그인/로그아웃 API 완료 (실행 테스트 통과)
- [x] **domain/point** — 낚시 포인트 CRUD + 방문기록(채비/미끼/날씨/조석) 완료
- [x] **global/external** — 날씨·조석 클라이언트 인터페이스 (Stub 구현)
- [ ] domain/diary — 낚시 일지 CRUD
- [ ] domain/prediction — 날씨·조석 API 연동 (Stub → 실제 API 교체)
- [ ] domain/community — 커뮤니티 게시판

---

## 예정 외부 API

- 해양수산부 조석 예보 API
- 기상청 단기예보 API (OpenAPI)
- 네이버맵 API
- Firebase Cloud Messaging (푸시 알림)

---

## 수익 모델

- AdMob 광고 (기본)
- 프리미엄 구독: 2,900원/월 (광고 제거 + 고급 예측)

---

## 다음 개발 단계 (MVP)

1. ~~**회원 도메인** - 회원가입/로그인, JWT 인증~~ ✅ 완료
2. ~~**포인트 도메인** - 낚시 장소 CRUD + 방문기록(채비/미끼/날씨/조석)~~ ✅ 완료
3. **일지 도메인** - 조황 기록 CRUD
4. **예측 도메인** - 날씨·조석 API 연동
5. **공유 도메인** - 커뮤니티 게시판

---

## 패키지 구조

```
com.fishingapp
├── domain
│   ├── user              # 회원 ✅
│   │   ├── controller    # AuthController (signup/login/logout)
│   │   ├── dto           # SignUpRequest, LoginRequest, AuthResponse
│   │   ├── entity        # User (UserDetails 구현), UserRole
│   │   ├── repository    # UserRepository
│   │   └── service       # UserService (UserDetailsService 구현)
│   ├── point             # 낚시 포인트 ✅
│   │   ├── controller    # FishingPointController, PointVisitController
│   │   ├── dto           # PointCreate/Update/Response, PointVisitCreate/Update/Response, TackleEntryRequest/Response
│   │   ├── entity        # FishingPoint, PointVisit, TackleEntry, WeatherInfo(@Embeddable), TideInfo(@Embeddable)
│   │   ├── repository    # FishingPointRepository, PointVisitRepository
│   │   └── service       # FishingPointService, PointVisitService
│   ├── diary             # 낚시 일지 (예정)
│   ├── prediction        # 조과 예측 (예정)
│   └── community         # 공유/커뮤니티 (예정)
├── global
│   ├── config            # SecurityConfig, JwtAuthenticationFilter, RedisConfig, JwtProperties ✅
│   ├── exception         # GlobalExceptionHandler, ErrorResponse ✅
│   ├── external          # WeatherClient, TideClient 인터페이스 + Stub 구현 ✅
│   └── util              # JwtTokenProvider ✅
```

## 구현된 API 엔드포인트

| Method | URL | 인증 | 설명 |
|--------|-----|------|------|
| POST | /api/auth/signup | 불필요 | 회원가입 (mapProvider 선택: NAVER/KAKAO) |
| POST | /api/auth/login | 불필요 | 로그인 |
| POST | /api/auth/logout | Bearer 토큰 | 로그아웃 (Redis 블랙리스트) |
| POST | /api/points | Bearer 토큰 | 낚시 포인트 등록 |
| GET | /api/points | Bearer 토큰 | 내 포인트 목록 |
| GET | /api/points/{id} | Bearer 토큰 | 포인트 상세 |
| PUT | /api/points/{id} | Bearer 토큰 | 포인트 수정 |
| DELETE | /api/points/{id} | Bearer 토큰 | 포인트 삭제 |
| POST | /api/points/{id}/visits | Bearer 토큰 | 방문기록 등록 (채비/미끼 + 날씨/조석 자동) |
| GET | /api/points/{id}/visits | Bearer 토큰 | 방문기록 목록 |
| GET | /api/points/{id}/visits/{visitId} | Bearer 토큰 | 방문기록 상세 |
| PUT | /api/points/{id}/visits/{visitId} | Bearer 토큰 | 방문기록 수정 |
| DELETE | /api/points/{id}/visits/{visitId} | Bearer 토큰 | 방문기록 삭제 |

## 보안 적용 내역

- JWT secret / DB password / Redis password 환경변수 분리 (`${VAR:default}` 형식)
- 운영 환경변수: `JWT_SECRET`, `DB_PASSWORD`, `REDIS_PASSWORD`, `JPA_DDL_AUTO=validate`, `JPA_SHOW_SQL=false`
- 로그아웃 시 Redis 블랙리스트로 즉시 토큰 무효화
- 인증/인가 실패 → JSON 에러 응답 (AuthenticationEntryPoint/AccessDeniedHandler)
- 위조 토큰 시도 warn 로그 기록

---

## 서비스 실행 방법

PostgreSQL 및 Redis가 실행 중이어야 합니다.

```powershell
# PATH 설정 (VS Code 터미널에서 새 세션일 때)
$env:PATH = "$env:USERPROFILE\scoop\shims;$env:USERPROFILE\scoop\apps\git\current\cmd;$env:PATH"

# PostgreSQL 시작 (실제 데이터 경로: scoop\persist)
pg_ctl start -D "$env:USERPROFILE\scoop\persist\postgresql\data" -l "$env:USERPROFILE\scoop\persist\postgresql\data\postgresql.log"

# PostgreSQL 상태 확인
pg_ctl status -D "$env:USERPROFILE\scoop\persist\postgresql\data"

# Redis 시작
Start-Process -FilePath "redis-server" -WindowStyle Hidden
redis-cli ping  # PONG 확인

# 빌드 및 실행
.\gradlew.bat bootRun
```
