#  RCManager
## Realm 패키지 의존 모듈 
### RCManager란?
+ RCManager (Reference Count Manager)는 참조 계수 매니저로 Swift와 Objective-C의 메모리 관리 기법에서 비롯함.
+ 샌드박스 내부(로컬)에서 저장해야하는 파일 (이미지, docs 등등...)의 여러 로컬 DB에서 사용하는 경우 파일을 중복 생성해서 보관하는 것을 방지하기 위함
+ 각각의 디비 레코드에서 특정 파일의 이름들 보관하는 경우 Reference Count 1 증가
+ 특정 파일의 이름을 삭제하는 경우 Reference Count 1 감소...
+ Reference Count가 0인 경우 해당 파일 삭제 및 참조 계수 매니저 테이블에 해당 레코드 삭제

### RCManager 생성 지침
1. Snapshot 기법 적용, 하나의 파일 타입(이미지, 영상, 문서 등등...)에 대응하는 하나의 싱글톤 매니저 인스턴스로 관리
2. 싱글톤 인스턴스에서 snapshot을 얻어와 값들을 갱신하고 해당 싱글톤에서 적용(apply)시, 데이터를 업데이트 하는 구조
