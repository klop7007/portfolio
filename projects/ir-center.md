# IR Center — 주주·투자자 대상 IR 웹사이트

> 상장사 IR(Investor Relations) 채널을 위한 회원제 웹사이트.
> 본인인증 기반 회원가입, 비밀글 게시판, FAQ, 관리자 콘솔을 Next.js 14 + MS SQL Server 위에 구축했습니다.

| 항목 | 내용 |
|---|---|
| 기간 | 2026.04 ~ 2026.07 (약 11주, 이후 유지보수) |
| 역할 | 1인 풀스택 — 기획 협의 · 설계 · 개발 · DB · 보안 점검 · 배포 · 운영 |
| 규모 | TypeScript/JS 약 13,600줄, 테이블 20개, 마이그레이션 8건, 커밋 99건 |
| 스택 | Next.js 14 (App Router, Server Actions), TypeScript, Tailwind CSS, MS SQL Server 2014, mssql/tedious, jose(JWT), bcrypt, nodemailer, PortOne V2 본인인증, Kakao OAuth |
| 인프라 | Linux 공용 웹서버 vhost 합류 — Apache(443 TLS 종단) + nginx(80 리다이렉트) → Next.js, PM2/systemd 상주 |

---

## 1. 배경과 문제

- 회사 IR 정보가 홈페이지 공시 페이지에만 흩어져 있어, 주주가 질문을 남기거나 회사가 답변을 관리할 창구가 없었음
- 주주 게시판은 **실명 확인이 된 사용자만** 글을 쓸 수 있어야 하고, 개인정보(이름·전화·CI)는 최소한만 보관해야 함
- 운영 DB가 **MS SQL Server 2014** 로 고정되어 있어 최신 SQL 문법을 쓸 수 없는 제약
- 신규 서버 없이 **기존 공용 웹서버에 서비스를 합류**시켜야 하는 조건 (다른 서비스 무중단 유지)

## 2. 아키텍처

```
Browser ──► Apache :443 (TLS) ──► Next.js :3001
              nginx :80 → 443        │
                                     ├─ Server Component (SSR, force-dynamic)
                                     ├─ Server Action / Route Handler ─┐
                                     └─ Client Component (폼 상태만)   │
                                                                       ▼
                                          lib/*.ts  (DAL, server-only) ──► MSSQL 2014
                                          lib/session.ts   httpOnly JWT
                                          lib/portone.ts   본인인증 API
                                          lib/mail.ts      SMTP
```

**3-tier 데이터 흐름을 강제하는 규칙**을 두고 개발했습니다.

1. **DAL (`lib/*.ts`)** — `server-only` 로 클라이언트 import 차단. 모든 쿼리는 파라미터 바인딩, 문자열 보간 금지
2. **Server Action / Route Handler** — 클라이언트 인자를 믿지 않고 항상 서버에서 세션을 재검증한 뒤 DAL 호출, `revalidatePath` 로 캐시 무효화
3. **Client Component** — 폼 상태만 관리, 결과는 Server Action 반환값으로 처리

## 3. 핵심 구현

### 3-1. 본인인증 기반 회원가입 (PortOne V2)

카카오/네이버/PASS 등 여러 인증 수단을 PortOne 통합 채널 하나로 연동하고, **검증 결과를 클라이언트가 조작할 수 없도록** 설계했습니다.

- 브라우저 SDK로 인증 → 서버가 PortOne API 로 `VERIFIED` 상태를 직접 재확인
- 검증된 이름·전화·CI 를 **서버 발급 단기 브릿지 토큰(httpOnly, TTL 10분)** 에 봉인
- 회원가입 API는 브릿지 토큰만 신뢰 — 클라이언트가 보낸 개인정보 필드는 무시
- 본인 식별자는 CI. 같은 CI 재가입은 인증 수단과 무관하게 차단(중복가입 방어), 운영 환경에서 CI 없는 가입은 거부
- 초기에 카카오·네이버 OAuth 직접 연동과 KG이니시스 직접 연동을 거쳐 PortOne 으로 통합 — 연동처 3곳을 1곳으로 줄여 유지보수 비용 절감

### 3-2. 세션 관리와 즉시 무효화 (Session Epoch)

- httpOnly 쿠키 + jose JWT(HS256). 페이로드에 `kind: admin | user` 로 관리자·회원 세션 분리
- **JWT 의 한계(발급 후 취소 불가)를 DB `session_epoch` 컬럼으로 보완** — 회원 정지·비밀번호 변경 시 epoch +1 → 기존 토큰 즉시 무효
- 고위험 액션(글 삭제, 관리자 답변, 게시판 설정, 회원 상태 변경)에만 epoch 검증을 추가해 일반 조회 성능은 유지
- 구버전 토큰(epoch 없음)은 graceful 통과시켜 배포 시 강제 로그아웃 없이 전환

### 3-3. 비밀글 게시판 권한 모델

- 목록과 상세 **양쪽에서 동일한 `resolvePostVisibility(board, post, viewer)` 판정 함수**를 사용해 우회 경로 차단
- 권한 부족 시 DAL 이 본문·답변을 **서버에서 NULL 로 마스킹**한 뒤 반환 — 클라이언트에 원문이 내려가지 않음
- 작성자명 중간 마스킹(김민우 → 김*우), 관리자/IR 답변은 실명 표시
- 원글/관리자 답변 depth 스레드 구조, soft delete

### 3-4. 레거시 DB(MSSQL 2014) 대응

- 2016+ 전용 구문(`STRING_AGG`, `DROP IF EXISTS`, `JSON_VALUE`, `CREATE OR ALTER`, `TRIM`) 금지 규칙을 문서화하고 코드 리뷰 기준으로 사용
- Node 18/OpenSSL 3 가 SQL Server 2014 의 SHA-1 인증서를 거부하는 문제 → TLS `SECLEVEL=0` 설정으로 연결 복구
- Next.js 가 `mssql`/`tedious` 를 번들링하면서 타입 prototype 이 깨지는 문제 → `serverComponentsExternalPackages` 등록으로 해결
- 커넥션 풀을 `globalThis` 에 캐시해 dev 핫리로드 시 풀 누수 방지, 실패한 풀은 캐시하지 않고 리셋
- `GO` 배치 분할 + pre/post-check 를 포함한 자체 마이그레이션 러너 작성, 마이그레이션 8건 운영 적용

### 3-5. 보안 자체 점검

출시 전 인증 흐름을 CWE 기준으로 점검하고 보고서로 남긴 뒤 수정했습니다.

| 등급 | 항목 | 조치 |
|---|---|---|
| CRITICAL | CWE-639 임의 계정 비밀번호 변경 가능 | 브릿지 토큰 기반으로 본인인증 결과와 대상 계정 강제 결합 |
| HIGH | CWE-489 테스트용 폴백 식별자 운영 잔존 | 운영 환경에서 폴백 경로 제거 |
| HIGH | CWE-613 비밀번호 변경 후 기존 세션 유지 | Session Epoch 도입 (3-2) |
| HIGH | CWE-307 인증 라우트 무차별 대입 방어 없음 | 슬라이딩 윈도우 rate-limit 추가 |
| HIGH | CWE-613 관리자 세션 무효화 부재 | 관리자 테이블에도 epoch 적용 |

## 4. 운영과 배포

- 신규 서버 없이 기존 공용 웹서버에 vhost 합류 — Apache 443 TLS 종단 + nginx 80 리다이렉트, 와일드카드 인증서 재사용
- PM2 / systemd 두 가지 상주 방식 준비, 배포 가이드·DNS 요청서·env 템플릿 문서화
- DB 점검·로그인 검증·시드·마이그레이션 적용 등 **운영 진단 스크립트 27종**을 read-only 원칙으로 작성해 장애 시 즉시 상태 확인 가능
- 개인정보처리방침 개정(접속기록 보관, 유출 통지 기한, CI 수집 항목) 반영

## 5. 개발 프로세스

- Conventional Commits (`feat/fix/style/chore/docs`) 로 99건 커밋, `ir-maint` 브랜치 작업 후 `master` 병합
- 아키텍처·금지 구문·보안 규칙을 `CLAUDE.md` 에 문서화하고 Claude Code 에이전트/훅을 프로젝트에 맞게 구성 — DB 접속 정보 자동 주입, 위험 명령 차단, 편집 후 규칙 리마인더 등을 훅으로 자동화해 AI 보조 개발의 안전장치 마련

## 6. 성과


- IR 웹사이트를 1인 풀스택으로 11주 만에 개발·배포, 인프라 추가 비용 0원.
- 카카오·네이버·PASS·토스 인증 4종을 PortOne 1채널로 통합, 서버 검증으로 위조 차단.
- 세션 즉시 폐기·비밀글 서버 마스킹 적용, 출시 후 인증 장애 0건.

## 7. 회고

- **잘한 것**: 클라이언트 입력을 신뢰하지 않는 원칙을 처음부터 구조(브릿지 토큰, 서버 세션 재검증, DAL server-only)로 강제해 이후 보안 점검에서 구조적 문제가 나오지 않음
- **아쉬운 것**: 자동화 테스트 없이 진단 스크립트로만 검증 — 다음 프로젝트에서는 인증 흐름만이라도 통합 테스트를 먼저 작성할 것
- **남은 리스크**: 인메모리 rate-limit 은 단일 프로세스 전제라 클러스터 확장 시 Redis 로 교체 필요
