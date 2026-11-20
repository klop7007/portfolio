# Portfolio

**김민우** — ERP · 그룹웨어 · 사내시스템 개발/운영 ([프로필](profile.md))

회사 업무로 진행한 프로젝트를 코드 공개 없이 정리한 문서입니다.
각 문서는 **문제 → 설계 → 구현 → 결과** 순으로 기록합니다.

## 핵심 역량

- **그룹웨어 · 전자결재 개발/운영** — Java · JSP · Spring 기반 그룹웨어를 현업 요구 분석부터 화면 · 쿼리 · 프로시저 · 배치까지 개발하고 운영
- **시스템 연계** — 그룹웨어–ERP 전자결재 · 근태 연동, 인사 · 조직 데이터 동기화, 이기종 DB(MS SQL–MySQL) 연동, REST API 개발
- **SQL · DB** — MS SQL Server · Oracle · PostgreSQL 쿼리 · 프로시저 개발과 튜닝, 데이터 이관 · 백업 · 복구
- **운영 · 보안** — 장애 대응과 사용자 지원, 서버 · 방화벽 · 접근권한 관리, IT 감사 대응

## 경력

<table>
  <tr><th nowrap>기간</th><th nowrap>회사</th><th>주요 업무</th></tr>
  <tr><td nowrap>2024.08 ~ 현재</td><td nowrap>(주)누리플렉스</td><td>ERP · 그룹웨어 · 사내시스템 개발/운영, DB · 인프라 · 정보보안 운영</td></tr>
  <tr><td nowrap>2023.07 ~ 2024.07</td><td nowrap>노브랜드</td><td>Delphi · Oracle 기반 사내 ERP 개발</td></tr>
  <tr><td nowrap>2020.07 ~ 2023.06</td><td nowrap>(주)누리플렉스</td><td>ERP(.NET) · 그룹웨어(Java · JSP) 개발/유지보수</td></tr>
  <tr><td nowrap>2018.02 ~ 2020.06</td><td nowrap>(주)에스엔테크놀로지</td><td>그룹웨어 솔루션 고객사 커스터마이징(Java · Spring)</td></tr>
</table>

## 프로젝트

### 2024 ~ 현재 · (주)누리플렉스

<table>
  <tr><th nowrap>프로젝트</th><th nowrap>기간</th><th>요약</th></tr>
  <tr><td nowrap><a href="projects/2026-08-erp-platform.md">통합 ERP 플랫폼 1단계</a></td><td nowrap>2026.08~</td><td>레거시 3종 통합 DB 이관 + FastAPI 조회 API + MCP 서버, 운영 배포 (진행 중)</td></tr>
  <tr><td nowrap><a href="projects/2026-08-attendance-dx.md">근태 연동 DX</a></td><td nowrap>2026.08~09</td><td>전자결재 신청서 구조화 → ERP 지각 판정 배치, 수기 대조 제거 (JSP · T-SQL)</td></tr>
  <tr><td nowrap><a href="projects/2026-07-fx-rate-collector.md">비고시환율 자동 수집</a></td><td nowrap>2026.07~08</td><td>은행 웹 수집 → ERP 적재 배치, 수동 입력 100% 자동화 (PowerShell · MSSQL)</td></tr>
  <tr><td nowrap><a href="projects/2026-04-ir-center.md">상장사 IR 웹 서비스</a></td><td nowrap>2026.04~07</td><td>본인인증 회원제 IR 사이트 1인 구축 · 배포 (Next.js 14 · MSSQL)</td></tr>
  <tr><td nowrap><a href="projects/2026-03-work-management.md">전사 업무관리 시스템</a></td><td nowrap>2026.03~04</td><td>M/M 가동률 대시보드 · 그룹웨어 인사 동기화, 공동 개발 (PostgreSQL · MSSQL)</td></tr>
  <tr><td nowrap><a href="projects/2026-01-groupware-modernization.md">그룹웨어 레거시 현대화</a></td><td nowrap>2026.01~02</td><td>JSP 380페이지 UI 전면 개편 + SQL Injection 제거, 무중단 전환 (Java · Spring · MyBatis)</td></tr>
</table>

### 2023 ~ 2024 · 노브랜드

<table>
  <tr><th nowrap>프로젝트</th><th nowrap>기간</th><th>요약</th></tr>
  <tr><td nowrap><a href="projects/2023-12-delphi-erp-automation.md">Delphi ERP 자동화</a></td><td nowrap>2023.12~2024.06</td><td>바코드 · FTP 이미지 · PPT 자동 생성 3건, PPT 제작 1시간 → 1분 (Delphi · DataSnap)</td></tr>
</table>

### 2020 ~ 2023 · (주)누리플렉스

<table>
  <tr><th nowrap>프로젝트</th><th nowrap>기간</th><th>요약</th></tr>
  <tr><td nowrap><a href="projects/2021-02-groupware-erp-improvements.md">그룹웨어·ERP 기능 개선 4건</a></td><td nowrap>2021.02~2023.02</td><td>통합 검색 10초 → 1초, 휴가 결재라인 자동 지정, 익명 게시판, 자격사항 (JSP · MSSQL)</td></tr>
  <tr><td nowrap><a href="projects/2020-10-erp-integration.md">ERP 연동 화면 2건</a></td><td nowrap>2020.10~2021.01</td><td>자금일보 ERP→그룹웨어, ERP–WMS 이기종 DB 비교 (JSP · MSSQL · MySQL)</td></tr>
  <tr><td nowrap><a href="projects/2020-07-groupware-workflows.md">그룹웨어 업무 화면 3건</a></td><td nowrap>2020.07~2023.04</td><td>장비 예약 · 거래처 평가 · 근태 캘린더 단독 개발 (JSP · MSSQL)</td></tr>
</table>

### 2018 ~ 2020 · (주)에스엔테크놀로지

<table>
  <tr><th nowrap>프로젝트</th><th nowrap>기간</th><th>요약</th></tr>
  <tr><td nowrap><a href="projects/2018-02-groupware-customizing.md">그룹웨어 솔루션 커스터마이징</a></td><td nowrap>2018.02~2020.06</td><td>고객사 맞춤 개발 · 계정 자동 잠금 · 패키지 유지보수 (Java · Spring · Oracle)</td></tr>
</table>
