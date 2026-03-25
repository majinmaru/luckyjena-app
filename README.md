# Lotto Web App (GitHub Pages + Supabase)

이 버전은 GitHub Pages에서 그대로 배포할 수 있고, `localStorage`만 쓰던 티켓 저장 기능에 **Supabase 로그인 + 사용자별 클라우드 저장**을 붙인 버전입니다.

## 포함된 로그인 / 저장 기능

- 이메일 + 비밀번호 회원가입
- 이메일 + 비밀번호 로그인
- 로그아웃
- 비밀번호 재설정 메일 전송
- 재설정 링크 진입 후 새 비밀번호 변경
- 로그인 상태 세션 유지
- 사용자별 티켓 클라우드 저장 / 다시 불러오기
- 기존 이 기기 localStorage 티켓 자동 병합

## 파일 구조

```text
index.html
supabase-config.js
supabase-config.example.js
supabase/setup.sql
data/
.github/
scripts/
```

## 배포 전 준비

### 1) Supabase 프로젝트 생성

Supabase에서 새 프로젝트를 만든 뒤 URL과 **public anon key**를 확인합니다.

### 2) SQL 실행

Supabase Dashboard → SQL Editor에서 `supabase/setup.sql` 내용을 실행합니다.

### 3) Authentication 설정

Supabase Dashboard → Authentication에서 Email provider를 켭니다.

권장 설정:
- Enable email confirmations: 켜기
- Site URL: GitHub Pages 주소
- Redirect URLs: GitHub Pages 주소 추가

예시:
- `https://username.github.io/repository-name/`

### 4) 설정 파일 입력

루트의 `supabase-config.js`를 열고 실제 값으로 바꿉니다.

```js
window.SUPABASE_CONFIG = {
  url: 'https://your-project-ref.supabase.co',
  anonKey: 'your-public-anon-key',
};
```

> `anon key`는 브라우저에서 공개해도 되는 키입니다. 절대로 service_role key를 넣으면 안 됩니다.

### 5) GitHub Pages 배포

루트 파일들을 그대로 GitHub 저장소에 올리고 Pages를 `main / (root)`로 설정합니다.

## 동작 방식

- 로그아웃 상태: 기존처럼 이 브라우저 `localStorage`에 저장
- 로그인 상태: 티켓 변경 사항을 Supabase DB에 자동 동기화
- 로그인 직후: 현재 기기 local 티켓과 클라우드 티켓을 자동 병합
- 새 기기 로그인: 클라우드 티켓을 불러와 같은 계정 데이터 사용

## 주의

- 처음 회원가입하면 이메일 인증 후 로그인해야 할 수 있습니다.
- 비밀번호 재설정은 Supabase의 메일 링크를 통해 진행됩니다.
- `supabase-config.js`를 실제 값으로 바꾸지 않으면 앱은 로컬 모드로만 동작합니다.
