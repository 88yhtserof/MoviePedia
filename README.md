# 🎬 무비피디아 (MoviePedia)

> **추천, 검색, 저장 기능을 통해 사용자가 보고 싶은 영화를 쉽게 찾고 관리할 수 있는 영화 큐레이션 앱입니다.**

<br>

## 📅 개발 기간

- 2025.01.24 ~ 2025.02.01 (총 9일)
- 개인 프로젝트 (1인 개발)


<br>

## 🌟 핵심 기능

- 오늘의 영화 추천
- 영화 검색 및 상세 정보 확인
- 보고 싶은 영화 저장
- MBTI, 닉네임, 이미지 기반 프로필 사용자화

<br>

## ⚙️ 상세 구현 사항

- **UX 일관성 유지**: 닉네임 입력 시 유효성 검사를 통해 예외 상황 방지
- **안정적인 네트워킹**: 상태 코드 기반 에러 핸들링으로 사용자에게 명확한 안내 제공
- **최근 검색어 기능**: 사용자의 검색 이력을 저장하고, 손쉬운 재검색 지원
- **상태 동기화**: 화면 간 ‘보고 싶은 영화’ 정보가 실시간으로 동기화
- **Pagination 처리**: offset 기반 페이징으로 메모리 최적화 및 빠른 로딩 속도 제공
- **이미지 로딩 인디케이터**: 로딩 중 상태 표시로 사용자 경험 개선


<br>

## 🛠 사용 기술

- **플랫폼**: iOS
- **언어 및 프레임워크**: Swift, UIKit
- **아키텍처**: MVVM (Input/Output 패턴 적용)
- **데이터관리**:
  - `UserDefaults` – 경량 데이터 저장 및 검색어 관리
- **라이브러리**:
  - `SnapKit` – UI 레이아웃 구성
  - `Kingfisher` – 이미지 비동기 로딩 및 캐싱
  - `Alamofire` – 네트워크 통신



<br>

## 📸 스크린샷

<!-- 아래 이미지들을 실제 경로에 맞춰 수정하세요 -->
| Cinema | 영화 상세 | 영화 검색 | 프로필 설정 | 프로필 이미지 설정 |
|:--:|:--:|:--:|:--:|:--:|
| ![Cinema](https://github.com/user-attachments/assets/10ef03ad-00a4-4e67-89bf-4539e5424069) | ![영화 상세](https://github.com/user-attachments/assets/098d8fff-6817-4a30-bfc0-3bf32014fffe) | ![영화 검색](https://github.com/user-attachments/assets/c81d54db-8d5b-48c1-90d2-3cfd064f0a0e) | ![프로필 설정](https://github.com/user-attachments/assets/e9e9f522-2681-4072-9447-849fffcc94ad) | ![프로필 이미지 설정](https://github.com/user-attachments/assets/d05ecab5-8da4-4fc2-b639-441c65167d30) |

| 미리보기 |
|:--:|
| ![미리보기](https://github.com/user-attachments/assets/9325b973-0bf8-4617-886b-664d88d92e6a) |

<br>
