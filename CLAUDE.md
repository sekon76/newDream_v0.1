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

## 현재 프로젝트 상태 (2026-07-15 기준)

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
- [x] **domain/prediction** — KMA(기상청)/KHOA(해양수산부) 실 API 연동 완료 (Stub 아님). 해안 25km 초과 시 "예측 불가" 처리
- [x] **domain/community** — 커뮤니티 피드/글쓰기/좋아요/댓글 완료. 게시글은 별도 엔티티가 아니라 `isPublic=true`인 `PointVisit`. 포인트를 공개로 전환하면 `[포인트 공개]` 게시글 자동 생성
- [x] **global/external** — 날씨·조석 클라이언트 (KMA/KHOA 실 연동)
- [x] Flutter 앱 — 인증/포인트/예측/커뮤니티 화면 구현, Android 에뮬레이터 실기 테스트 완료
- [ ] domain/diary — 독립된 "낚시 일지" 도메인 (현재는 point/PointVisit + CatchRecord로 조황 기록을 대신하고 있음, 별도 화면·API 없음)
- [ ] 수익 모델 — AdMob 광고, 프리미엄 구독 (미착수)

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
3. ~~**예측 도메인** - 날씨·조석 API 연동~~ ✅ 완료 (KMA/KHOA 실 API)
4. ~~**공유 도메인** - 커뮤니티 게시판~~ ✅ 완료 (피드/글쓰기/좋아요/댓글/포인트 공개 연동)
5. **일지 도메인** - 독립된 낚시 일지 CRUD (필요 여부 검토 중 — 현재 point/PointVisit이 대신 담당)
6. **수익 모델** - AdMob 광고, 프리미엄 구독

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
│   │   └── service       # FishingPointService (포인트 공개 시 커뮤니티 자동게시 포함), PointVisitService
│   ├── prediction        # 조과 예측 ✅
│   │   ├── controller    # PredictionController, HourlyPredictionController
│   │   └── service       # PredictionService (KMA/KHOA 연동, 해안 25km 밖은 예측 불가 처리)
│   ├── community         # 공유/커뮤니티 ✅ (게시글 = isPublic PointVisit)
│   │   ├── controller    # CommunityController (/api/community)
│   │   ├── entity        # PostLike, Comment
│   │   └── service       # CommunityService, LikeService, CommentService
│   └── diary             # 낚시 일지 (미착수 — 현재 point 도메인이 역할 대신 수행)
├── global
│   ├── config            # SecurityConfig, JwtAuthenticationFilter, RedisConfig, JwtProperties ✅
│   ├── exception         # GlobalExceptionHandler, ErrorResponse ✅
│   ├── external          # WeatherClient(KMA)/TideClient(KHOA) 실 연동 구현 ✅
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
| GET | /api/predictions | Bearer 토큰 | 위치 기반 조과 예측 (KMA/KHOA 연동) |
| GET | /api/predictions/hourly | Bearer 토큰 | 시간대별 예측 |
| GET | /api/community/posts | Bearer 토큰 | 커뮤니티 피드 목록 |
| GET | /api/community/posts/{visitId} | Bearer 토큰 | 게시글 상세 |
| POST/DELETE | /api/community/posts/{visitId}/likes | Bearer 토큰 | 좋아요 등록/취소 |
| GET/POST | /api/community/posts/{visitId}/comments | Bearer 토큰 | 댓글 목록/작성 |
| PUT/DELETE | /api/community/comments/{commentId} | Bearer 토큰 | 댓글 수정/삭제 |

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
# PostgreSQL 시작 (실제 데이터 경로: C:\PostgreSQL\data)
pg_ctl start -D "C:\PostgreSQL\data" -l "C:\PostgreSQL\data\postgresql.log"

# PostgreSQL 상태 확인
pg_ctl status -D "C:\PostgreSQL\data"

# Redis 시작 (실제 실행파일 경로: C:\Redis\redis-server.exe)
Start-Process -FilePath "C:\Redis\redis-server.exe" -WindowStyle Hidden
redis-cli ping  # PONG 확인

# 빌드 및 실행 (KMA/KHOA API 키는 환경변수로 주입)
$env:KMA_API_KEY = "..."
$env:KHOA_API_KEY = "..."
.\gradlew.bat bootRun
```

## Android 에뮬레이터 테스트 (ADB)

```powershell
$adb = "C:\Android\sdk\platform-tools\adb.exe"

# 정확한 탭 좌표가 필요할 때: UI 계층을 덤프해서 bounds를 직접 확인
& $adb shell uiautomator dump /sdcard/ui.xml
& $adb pull /sdcard/ui.xml C:\Android\ui.xml

# 스크린샷
& $adb shell screencap -p /sdcard/screen.png
& $adb pull /sdcard/screen.png C:\Android\screen.png
```

**주의**: 스크린샷을 볼 때 표시되는 이미지 크기(예: 900x2000)와 실기기 좌표(1080x2400)가 다를 수 있다.
반드시 `uiautomator dump`로 얻은 실제 `bounds` 값으로 탭 좌표를 계산할 것 — 표시된 이미지 좌표를 그대로 쓰면 엉뚱한 곳을 탭하게 된다.
