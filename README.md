# “To.Nest” 협업 플랫폼 프로젝트

> To.Nest로 팀을 꾸리고 각자의 관심사 대해 소통하세요
> 
![Group_13x](https://github.com/user-attachments/assets/b035aad8-783f-4855-9f2b-6856c661b674)


### 프로젝트 요약

- 유저 간 **[팀(워크스페이스) > 대화방(채널,DM) 메시지]**(으)로 소통하는 서비스 구조
- 개인 프로젝트 (외부에서 제공 받은 API 사용)
- 2024.01.02 ~ 2024.02.28 (8주)
- iOS App - Minimum deployment target **16.0**

진행 기간: 2024.01 ~ 2024.02

#### 💡 서버와 함께 진행한 업무용 협업 툴 플랫폼 프로젝트입니다.

### 사용 기술 목록

| **Services, Technology** | **Stack** |
| --- | --- |
| Architectrue | UDF(ReactorKit), MVVM |
| Asynchronous | RxSwift, Swift Concurrency, Combine |
| Network | [Socket.IO](http://socket.io/), Alamofire |
| UI | UIKit(SnapKit), SwiftUI, Modern Collection View |
| Pay | PG Pay - Iamport |
| DataBase | RealmSwift |
| Cache, Storage | NSCache, UserDefaults, Documents |
| Apple APIs | CoreImage, ShareLink, Photos, AuthenticationServices |
| Custom Serivice | ReferenceCounter, TaskCounter |
| Push Notification | Firebase Cloud Messaging, UNNotification |

# IA 설계

<p align = "center">
<img width="800" alt="IA%E1%84%89%E1%85%A5%E1%86%AF%E1%84%80%E1%85%A8" src="https://github.com/user-attachments/assets/ba1866fe-5ad7-4eb1-852b-99fe9d9fea23">
</p>

# 전체 구조

<p align = "center">
<img width="800" alt="%E1%84%91%E1%85%B3%E1%84%85%E1%85%A9%E1%84%8C%E1%85%A6%E1%86%A8%E1%84%90%E1%85%B3%E1%84%8C%E1%85%A5%E1%86%AB%E1%84%8E%E1%85%A6%E1%84%80%E1%85%AE%E1%84%8C%E1%85%A9" src="https://github.com/user-attachments/assets/f4d84cca-3970-4028-9eaa-5b0b44e836a4">
</p>

## 주요 제공 서비스

### 1. Real Time Chatting


<table>
  <tr>
    <th>Sender</th>
    <th>Receiver</th>
  </tr>
  <tbody>
    <td> <video src = "https://github.com/user-attachments/assets/f76fa7ff-4c19-4f54-81fd-24cb88814368"></video> </td>
    <td> <video src = "https://github.com/user-attachments/assets/ffe41497-9559-4043-8975-b898643036b6"></video> </td>
  </tbody>
</table>






### 2. FCM - **APNs**


<table>
  <tr>
    <th>Foreground Notification</th>
    <th>Background Notification</th>
    <th>Sleep Notification</th>
  </tr>
  <tbody>
    <td colspan="3"> <video src = "https://github.com/user-attachments/assets/1f0c62a0-393a-4316-badb-1179110d3f53"></video> </td>
  </tbody>
</table>

### 3. Link PG with “iamport” Library

https://github.com/user-attachments/assets/ad0009cb-1a3d-40a7-88c3-b14c2f5fc32b



    

### 주요 기술 구현 특징

| **Keyword** | **Description Link** |
| --- | --- |
| **Image Caching** | [**iOS - 채팅창 프로필 이미지 중복 사용 방지 처리**](https://arpple.tistory.com/40) |
| **SwiftUI** | [**PG 결제 상품 리스트 API 호출 오류 with StateObject vs ObservedObject**](https://arpple.tistory.com/41) |
| **UICollectionView** | [**iOS 16부터 UIHostingConfiguration으로 UICollectionViewCell 만들기**](https://arpple.tistory.com/66) |
| **Concurrency** | TaskCounter를 통해 사용자 앨범에서 이미지 가져오기 |

## 회고

### 단방향 아키텍처 ReactorKit와 페이지 구성

네트워크, 앨범 접근, 채팅, DB 저장 등 다양한 도메인 및 데이터 의존성 코드의 역할 분리의 필요성으로
단방향 아키텍처를 선택
그 결과, 유저 액션과 값 변화를 분리하여 개발 진행할 수 있었음
하지만 ReactorKit이 화면 전환 간 로직 처리가 복잡해지는 문제를 해결하진 못함

화면 처리가 복잡해진 예시

- Modal Sheet를 내린 후 특정 페이지로 전환
- 채팅 Push Notification 시, 채팅 내용 최신화 후 채팅창으로 바로 전환

### UIHostingConfiguration 사용경험

WWDC22에서 소개된 UIHostingConfiguration으로 UIKit의 UIContentListCell을 SwiftUI의 뷰로 제작
빠르게 뷰를 만들었지만 채팅 내용에 맞게 데이터가 갱신되지 않는 문제 발생
SwiftUI View의 ViewModel이 ObservableObject 프로토콜을 준수하지 않은 것이 원인
UIHostingConfiguration은 SwiftUI의 View를 재사용 메커니즘을 사용하여, ViewModel에
ObservableObject을 채택해야 데이터 변화를 알려줄 수 있음
UIKit, SwiftUI 모두 작동 원리를 잘 이해 해야 함을 알게 됨

### Swift Concurrency 사용

Realm 기본 사항은 `MainActor`에서 DB 요청을 처리해 화면 처리에 딜레이가 발생하는 문제가 있었다.
이를 해결하기 위해 `@globalActor`를 이용해 Serial Global Custom Actor에서 Realm을 구동했다.
길고 복잡한 GCD 없이 RealmDB Update시 Race Condition이 발생하지 않았다.
하지만, 안전한 공통된 값을 가져와 다른 화면에 나태낼 때, 각각의 화면 렌더링이 동시에 발생하는 충돌이 발생했다.
화면이 데이터를 완전히 반영할 때까지 각각의 화면에 Delay를 주면서 Progress Bar를 띄우는 방법으로 문제를 해결했지만 아쉬움이 존재했다.

Task 변수를 할당 받아서 처리 지연에 대한 대응을 Background에서 자연스럽게 하는 방법을 늦게 찾아서 주어진 개발 기간동안 리팩토링하기 적절하지 않았고, 직접 적용하지 못 했기 때문이다.

### SwiftUI를 이용해 최소한의 UILibrary 사용

워크스페이스 슬라이더, 이미지 Crop 기능 화면에 SwiftUI를 적용해 빠르게 직접 구현
외부 라이브러리를 사용하는 것보다 시간 소요가 있었지만, 디자인 요구사항에 알맞은 자세한 여백, 간격을
설정할 수 있었음

<table>
  <tr>
    <th>수평 이미지 슬라이더</th>
    <th>이미지 Crop 뷰</th>
  </tr>
  <tbody>
    <td> <video src = "https://github.com/user-attachments/assets/73bae34f-2070-4649-9278-f25b835b6b23"></video> </td>
    <td> <video src = "https://github.com/user-attachments/assets/d6c9c8a4-0b54-46b3-83b3-3e0bd5b9595b"></video> </td>
  </tbody>
</table>
