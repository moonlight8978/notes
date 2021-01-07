Giới thiệu về Kubernetes

# 1. Kubernetes là gì?

Ngày nay, container đã là 1 thứ gì đó quá phổ biến, những nền tảng cloud của Amazon, Google, hay Microsoft, v.v... đều đã hỗ trợ deploy container. Và ở local, hay những server test, mọi người cũng đang dần chuẩn sang container vì sự tiện lợi của chúng.

Tuy nhiên khi số lượng container lớn dần, chúng ngày càng trở nên rắc rối, việc control resource, network, volume của một số lượng lớn container ngày càng khó. Chính vì lý do đó, một số nền tảng quản lý container đã ra đời như Docker Swarm, Kubernetes, ...

Với một hệ thống nhỏ, ta có thể sử dụng Docker Swarm, sử dụng nó rất dễ và đơn giản. Kubernetes cho phép ta customize nhiều thứ trong hệ thống hơn, tuy nhiên cái giá của nó là khó sử dụng hơn nhiều Docker Swarm.

Note: Ta không bao giờ so sánh Kubernetes với Docker, vì k8s thứ là management tool, còn docker là container runtime.

# 2. Kiến trúc hạ tầng của Kubernetes

![](https://images.viblo.asia/8fd57971-e1c9-41dd-b205-0ce88a356e50.png)

### 2.1 Master components

Những components trên master node sẽ đóng vai trò là control plane của cluster. VD như: scheduling các pod, ...

##### 2.1.1 etcd

Đây là database phân tán, sử dụng Raft làm cơ chế đồng thuận.

State của cluster (config, node info, IP addresses, ...) đều được lưu trữ tại đây.

##### 2.1.2 kube-scheduler

Có nhiệm vụ schedule pod tới những node có đủ resource, và đảm bảo pod đạt được expected status.

Có thể hiểu đơn giản đây là một vòng lặp vô tận, đưa những pod mới được tạo vào 1 queue, từng item trong đó sẽ được schedule tới node thỏa mãn.

##### 2.1.3 kube-apiserver

API Server đơn thuần là 1 REST API của Kubernetes cluster.

Khi muốn tạo, cập nhật, hay xóa những resource của hệ thống như pod, ingress, ... thì đều cần thông qua API Server, chứ không call thẳng tới kube-scheduler, etcd, ...

##### 2.1.4 kube-controller-manager

Chạy nhiều controller process. Mỗi controller có nhiệm vụ khác nhau như:

- Node Controller
- Replication Controller
- ...

### 2.2 Node components

Là những component được cài đặt trên tất cả các node, giúp quản lý container trên node, logging, quản lý network, ...

##### 2.2.1 kubelet

Có nhiệm vụ quản lý container, đảm bảo container chạy chính xác, kubelet chỉ quản lý container do k8s tạo.

##### 2.2.2 kube-proxy

Là một network proxy, dùng để forward request tới hạ tầng của k8s.

##### 2.2.3 Container runtime

Chắn chắn ta không thể thiếu runtime cho container, nó có thể là rkt, Docker, ... hay bất cứ thứ gì khác.

### 2.3 Hoạt động

Chúng ta sẽ cùng xem những component trên sẽ kết hợp với nhau hoạt động ra sao, thông qua việc tạo 1 Pod qua `kubectl` CLI.

**Pod** ở đây có thể coi là 1 máy ảo, hay 1 container như Docker cho dễ hình dung.

![](https://images.viblo.asia/f19795c9-fbc9-48e1-9391-53fc439c1391.jpg)

- Trước tiên ta sử dụng `kubectl` để yêu cầu tạo 1 Pod. Bản chất của command này là sẽ thực hiện 1 HTTP request tới **apiserver** của cluster.
- **apiserver** sẽ thực hiện ghi lại current state, và desired state của cluster lại vào **etcd** (asynchronous)
- **etcd** sẽ notify lại **apiserver** khi entry được tạo thành công
- Tiếp theo **kube-scheduler** sẽ thực hiện việc schedule Pod. Khi tìm thấy node thích hợp, nó sẽ báo cho **apiserver** là Pod đó đã được bind vào node nào. **apiserver** sẽ lại update vào **etcd**
- **kubelet** tại node đó sẽ thực hiện việc theo dõi container tạo bởi **container runtime** (Docker), xem chúng có chạy đúng với PodSpec không. **kubelet** sẽ gọi tới **apiserver** để update state của Pod đó thường xuyên.

# 3. Kiến trúc của ứng dụng trên Kubernetes

Ta sẽ chỉ tập trung vào 3 yếu tố chính để một hệ thống có thể hoạt động được:

- Ứng dụng
- Network
- Storage

### 3.1 Pod

##### Pod là gì

**Pod** là đơn vị nhỏ nhất trong cluster. Mỗi Pod có IP riêng, và có thể chứa nhiều container, những container trong cùng 1 Pod có thể giao tiếp với nhau qua localhost. Vì vậy, có thể coi Pod là một máy ảo cho dễ hình dung.

Tuy nhiên để đơn giản, người ta thường chỉ chạy 1 container trên mỗi Pod, khi đó ta sẽ làm việc với Pod thay vì với từng container riêng lẻ.

##### Init container

Pod có hỗ trợ init container (1 hoặc nhiều đều được). Trước khi app container (container chính - ví dụ container với command `rails s`) chạy, tất cả init container sẽ được chạy lần lượt, cái trước thành công rồi đến cái sau chạy.

Ví dụ như 1 ứng dụng Rails, ta có thể settings `rails s` làm app container, còn `rails db:create db:migrate` sẽ làm init container.

##### Controller

Controller là 1 concept trong Kubernetes, nó dùng để theo dõi 1 loại Resource nào đó. **kube-controller-manager** có nhiệm vụ quản lý những controller này.

Về mặt kỹ thuật thì đây đơn thuần là 1 vòng lặp vô hạn (_control loop_) để có thể điều chỉnh state của cluster sao cho nó đạt tới được desired state.

Tuy nhiên đang trong mục Pod nên ta sẽ chỉ đề cập tới controller theo dõi Pod trong phần này.

- `Deployment`:

  Ta sẽ sử dụng `Deployment` khi cần deploy 1 hoặc nhiều replica (thường là stateless).

  Thứ tự khởi động, identify của những replica (Pod) là hoàn toàn ngẫu nhiên.

- `StatefulSet`:

  Nếu app của chúng ta là stateful (ví dụ như 1 set MySQL với 1 master và 2 slave), khi đó việc có 1 stable identity là rất quan trọng. Ngoài ra với mỗi replica trong `StatefulSet`, Kubernetes sẽ cung cấp cho nó một storage riêng.

  `StatefulSet` thêm prefix `0`, `1`, `2`, ... là thứ tự khởi động của pod vào tên pod.

  Khi đó network identity, cũng như storage của Pod sẽ trở nên stable. Nếu mysql-0 của ta là master, nó sẽ luôn là master, và nó cũng luôn request tới storage của master.

- `DaemonSet`:

  Ta dùng `DaemonSet` trong trường hợp muốn tất cả các node đều phải chạy 1 Pod nào đó.

  Ví dụ như storage cluster như **glusterd**, hay log agent như **fluentd**, ...

- `Job`:

  Khi ta cần chạy one-off Pod. Ví dụ như việc import master data.

- `CronJob`:

  Như tên gọi của nó, cứ định kì nó sẽ tạo Pod để thực hiện job.

### 3.2 Networking

#### 3.2.1 Service

Trên môi trường production, rất hiếm khi ta thấy 1 service chỉ chạy trên 1 server. Thay vì thế, thường sẽ có 2 hoặc nhiều hơn server cùng chạy, khi server này chết, ta có thể forward request tới những server heo-thì (healthy) còn lại (trong trường hợp có set load balancer và healthcheck), không làm cho service của ta ngỏm luôn.

Tuy nhiên IP của Pod trong cluster luôn thay đổi, vậy thì ta biết phải setup cho load balancer như thế nào? Và đây chính là đất diễn của `Service`.

`Service` là một tập hợp các Pod, thường sẽ dùng `label` để group các Pod.

Thông thường, mỗi `Service` sẽ được gán cho 1 cluster IP, Kubernetes sẽ cung cấp DNS name, và đồng thời cũng load-balance cho các Pod của `Service`.

![](https://images.viblo.asia/2a7f4968-7280-47eb-a225-60ab2f06ab6e.png)

Ta cũng có thể sử dụng `Service` cho external endpoint.

Ví dụ khi hệ thống cần call đến _https://google.com.vn_. Tuy nhiên ta lại không muốn call trực tiếp, hay hardcode trong code, mà muốn endpoint này cũng trở thành 1 phần của cluster, để dễ quản lý. Khi đó ta có thể thay đổi endpoint này mà không phải đụng đến code, hay biến ENV gì đó. Khi đó, ta sẽ define 1 `Service`, và set `Endpoint` thủ công cho service này, thay vì sử dụng `label`.

Ngoài ra còn có `Headless Service`, loại service này sẽ không được gán cluster IP. Ta sẽ sử dụng khi ta muốn sử dụng cách load balance riêng, không phụ thuộc Kubernetes.

#### 3.2.2 Load balancer

Khi tạo Service, nếu đây là service cho phép traffic từ bên ngoài Internet, ta hoàn toàn có thể sử dụng Load Balancer của các nhà cung cấp dịch vụ cloud (thường là L3 Load Balancer).

Khi call tới Load Balancer nói trên, nó sẽ trực tiếp forward traffic tới service trong cluster, thuật toán load-balance sẽ do Load Balancer này quyết định.

![](https://images.viblo.asia/fdf97441-6cc1-4b42-ac48-342541d0421e.png)

#### 3.2.3 Ingress

`Ingress` hoạt động giống 1 Reverse Proxy hay Layer 7 Load Balancer. Nó cũng có nét tương đồng với API Gateway.

`Ingress` có thể điều hướng cả internal traffic lẫn external traffic dựa vào URL, đồng thời cung cấp thêm cả load balancing giữa những pod của service. Một điểm đáng lưu ý là `Ingress` sẽ load balance trực tiếp các backend Pod mà không thông qua service, do đó, ta có thể tùy chỉnh được thuật toán, ... liên quan tới LB cho toàn bộ `Ingress` của cluster.

Ngoài ra, người ta cũng dùng `Ingress` để terminate TLS session.

![](https://images.viblo.asia/5809feda-e282-4d5f-9cfb-11077d952add.jpg)

Kubernetes sau khi init mặc định sẽ không có ingress controller. Nếu ta chỉ tạo `Ingress` thì sẽ không có ý nghĩa gì. Để sử dụng `Ingress` ta sẽ phải setup thủ công Ingress Controller. Tuy nhiên việc này khá đơn giản, do nhiều hãng đã build sẵn mọi thứ, ta chỉ cần lấy file manifest của họ về rồi chạy là được.

- nginx: [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- traefik: [Kubernetes Ingress](https://docs.traefik.io/providers/kubernetes-ingress/)
- ...

#### 3.2.4 Practice

![](https://images.viblo.asia/5001a20e-979c-473f-b2da-92c8668f621e.png)

- Traffic từ phía client sẽ được tập trung tại Layer 4 Load Balancer.
- L4 LB sẽ phân bố traffic tới các Node trong cluster (thường qua `NodePort`).
- `Ingress` được map với `NodePort` đó sẽ terminate SSL, routing, và load balance traffic tới những Pod thích hợp.
  - Traffic tới `/web` sẽ được điều hướng tới Frontend Pods
  - Traffic tới `/api` sẽ được điều hướng tới Backend Pods

### 3.3 Storage - Volume

Một hệ thống khó có thể hoạt động chỉ với stateless service.

Với một số service như database, hay như tính năng upload file, ... Nếu chúng ta không sử dụng external service, thì service của ta sẽ trở thành stateful service. Nó đòi hỏi dữ liệu trong quá trình xử lý phải được lưu lại ngay cả khi bị crash. Ngoài ra có những lúc ta sẽ cần share dữ liệu giữa những container trong cùng 1 Pod. Những lúc như vậy, ta sẽ cần đến **Volume**.

Khi define Pod, ta sẽ chỉ rõ Pod này cần những volume nào, sau đó map những volume đó cho container.

##### PersistentVolume

Kubernetes sử dụng `PersistentVolume` để tạo nên 1 lớp abstract với những hệ thống storage thật phía sau. `PV` cũng có life-cycle giống như Pod.

Khi ta sử dụng volume, ta sẽ không cần quan tâm hệ thống đằng sau ngang dọc ra sao, thứ duy nhất ta cần quan tâm là API của `PersistentVolume`.

Trong Kubernetes, `PV` có thể được tạo bằng 2 cách:

- Dynamic Provisioning
- Static Provisioning

##### Static Provisioning

Admin cluster sẽ tạo ra 1 số `PV` trước, sau đó cung cấp cho bên Dev/Ops. Những `PV` này đã được trỏ tới hệ thống storage thật đang hoạt động đằng sau.

Có thể xem danh sách driver mà Kubernetes hỗ trợ tại [đây](https://kubernetes.io/docs/concepts/storage/volumes/#types-of-volumes).

Ví dụ: Ta có 1 cluster Glusterfs với 3 node, tổng dung lượng là 3TB. Khi cần 10GB cho việc lưu trữ share resource, ta sẽ tạo `PersistentVolume` với dung lượng 10GB, trỏ tới cluster nói trên. Sau đó ta sẽ sử dụng volume trên tương tự như các volume khác trong hệ thống.

##### Dynamic Provisioning

`PV` sẽ được tạo 1 cách động. Tức là khi nào Pod của ta cần volume, thì `PV` sẽ được tạo 1 cách tự động, nhờ vào `StorageClass` (sẽ đề cập sau).

Cách làm này đòi hỏi hệ thống storage của ta cũng phải support dynamic provisioning.

##### PersistentVolumeClaim

Để có thể sử dụng được `PV`, ta cần tạo thêm `PersistentVolumeClaim` (PVC).

Ta có thể sử dụng Claim trên cho config, hay volume, ... của Pod.

# 4. High Availability Setup

![](https://images.viblo.asia/48635fac-b09b-4174-b279-4f8d0fa29fb6.png)

# 5. Reference

kubernetes.io - [Kubernetes Official Documentation](https://documentationo/docs/home/)

youtube.com - [June 2018 Online Meetup: Kubernetes Networking Master Class](https://www.youtube.com/watch?v=GXq3FS8M_kw)

x-team.com - [INTRODUCTION TO KUBERNETES ARCHITECTURE](https://x-team.com/blog/introduction-kubernetes-architecture/)

ovh.com - [Getting external traffic into Kubernetes – ClusterIp, NodePort, LoadBalancer, and Ingress](https://www.ovh.com/blog/getting-external-traffic-into-kubernetes-clusterip-nodeport-loadbalancer-and-ingress/)

medium.com - [Kubernetes Master Components: Etcd, API Server, Controller Manager, and Scheduler](https://medium.com/jorgeacetozi/kubernetes-master-components-etcd-api-server-controller-manager-and-scheduler-3a0179fc8186)

medium.com - [Kubernetes NodePort vs LoadBalancer vs Ingress? When should I use what?](https://medium.com/google-cloud/kubernetes-nodeport-vs-loadbalancer-vs-ingress-when-should-i-use-what-922f010849e0)
