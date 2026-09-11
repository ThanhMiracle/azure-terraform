# Azure IAM, RBAC, Subscription Management & Governance

Tài liệu này tổng hợp các khái niệm quan trọng về **Identity & Access Management (IAM)**, **Azure RBAC**, **Subscription Management** và **Governance** trong Microsoft Azure.

---

# 1. Bức tranh tổng thể

Có thể hiểu Azure theo luồng đơn giản sau:

```text
Microsoft Entra ID
      |
      |  Who are you?
      v
Identity: User / Group / App / Managed Identity
      |
      |  What can you do?
      v
Azure RBAC
      |
      |  Where can you do it?
      v
Management Group / Subscription / Resource Group / Resource
      |
      |  What rules must everyone follow?
      v
Azure Governance
```

Cách nhớ nhanh:

- **Entra ID / IAM** -> Ai đang truy cập?
- **RBAC** -> Người đó được làm gì?
- **Subscription** -> Resource nằm ở đâu và được quản lý/billing như thế nào?
- **Governance** -> Tổ chức bắt buộc resource phải tuân theo những rule nào?

---

# 2. IAM trong Azure là gì?

**IAM (Identity and Access Management)** là cách Azure quản lý:

1. **Identity** - Ai đang truy cập?
2. **Authentication** - Làm sao chứng minh identity đó là thật?
3. **Authorization** - Identity đó được phép làm gì?

Trong Azure, phần identity chủ yếu được quản lý bởi **Microsoft Entra ID**.

## 2.1 Microsoft Entra ID

Microsoft Entra ID chứa các identity như:

```text
Microsoft Entra ID Tenant
|
|-- Users
|-- Groups
|-- Service Principals
|-- Managed Identities
`-- Applications
```

### User

Đại diện cho một người.

Ví dụ:

```text
thanh@company.com
```

User có thể đăng nhập Azure Portal, Azure CLI hoặc các ứng dụng của công ty.

### Group

Group là tập hợp nhiều user.

Ví dụ:

```text
DevOps-Team
|
|-- Thanh
|-- An
`-- Minh
```

Thay vì cấp quyền cho từng user:

```text
Thanh -> Contributor
An    -> Contributor
Minh  -> Contributor
```

nên cấp quyền cho group:

```text
DevOps-Team -> Contributor
```

Đây là cách dễ quản lý hơn trong môi trường enterprise.

### Service Principal

Service Principal là identity dành cho **application hoặc automation**.

Ví dụ:

```text
Jenkins
  |
  v
Service Principal
  |
  v
Azure Subscription
```

Jenkins có thể dùng Service Principal để deploy resource lên Azure.

### Managed Identity

Managed Identity cũng là identity dành cho Azure resource, nhưng Azure tự quản lý credential.

Ví dụ:

```text
Virtual Machine
      |
      | Managed Identity
      v
Key Vault
```

VM có thể đọc secret trong Key Vault mà không cần lưu username/password/client secret trong code.

---

# 3. Authentication và Authorization

Hai khái niệm này khác nhau.

## Authentication

Câu hỏi:

> **Who are you?**

Ví dụ:

```text
User -> Login -> Entra ID -> Authentication successful
```

Có thể sử dụng:

- Password
- MFA
- Certificate
- FIDO2 / Passkey
- Conditional Access

## Authorization

Câu hỏi:

> **What are you allowed to do?**

Ví dụ user đã login thành công nhưng chưa chắc có quyền tạo VM.

```text
Authentication
     |
     v
User is verified
     |
     v
Authorization / RBAC
     |
     v
Can this user create a VM?
```

Azure RBAC chịu trách nhiệm chính cho authorization đối với Azure resources.

---

# 4. Azure RBAC là gì?

**RBAC = Role-Based Access Control**.

RBAC quyết định:

> **Ai được làm gì và ở đâu?**

Công thức quan trọng nhất:

```text
Principal + Role + Scope = Access
```

Hoặc:

```text
WHO + WHAT + WHERE = ACCESS
```

---

# 5. Principal

Principal là đối tượng được cấp quyền.

Có thể là:

```text
User
Group
Service Principal
Managed Identity
```

Ví dụ:

```text
Principal = DevOps-Team
```

---

# 6. Role

Role xác định **Principal được phép làm gì**.

Một số built-in roles phổ biến:

| Role | Ý nghĩa |
|---|---|
| Reader | Chỉ xem resource |
| Contributor | Tạo, sửa, xóa resource nhưng không quản lý RBAC |
| Owner | Contributor + có thể quản lý quyền truy cập |
| User Access Administrator | Quản lý role assignments |

Ví dụ:

```text
DevOps-Team
     +
Contributor
```

Có nghĩa là DevOps Team được phép quản lý resource.

Nhưng vẫn còn một câu hỏi:

> Quản lý ở đâu?

Đây chính là **Scope**.

---

# 7. Scope

Scope xác định nơi role assignment có hiệu lực.

Azure resource hierarchy:

```text
Management Group
      |
      v
Subscription
      |
      v
Resource Group
      |
      v
Resource
```

Ví dụ:

```text
Principal = DevOps-Team
Role      = Contributor
Scope     = rg-app-dev
```

Kết quả:

```text
DevOps-Team
     |
     | Contributor
     v
rg-app-dev
|
|-- VM
|-- Storage Account
`-- Key Vault
```

DevOps Team có thể quản lý resource trong `rg-app-dev`.

Nhưng họ không tự động có quyền ở `rg-app-prod`.

---

# 8. RBAC inheritance

RBAC có tính kế thừa từ scope lớn xuống scope nhỏ.

Ví dụ cấp Reader tại Subscription:

```text
Subscription
   | Reader
   |
   |-- Resource Group A
   |      |-- VM
   |      `-- Storage
   |
   `-- Resource Group B
          `-- Database
```

User sẽ có Reader ở toàn bộ resource phía dưới subscription đó.

Nếu chỉ cấp tại Resource Group A:

```text
Resource Group A -> Reader
```

thì không tự động có quyền ở Resource Group B.

---

# 9. Role Assignment

Khi bạn kết hợp:

```text
Principal
+
Role
+
Scope
```

Azure tạo một **Role Assignment**.

Ví dụ:

```text
Principal : DevOps-Team
Role      : Contributor
Scope     : /subscriptions/xxx/resourceGroups/rg-dev
```

Đây chính là một RBAC role assignment.

---

# 10. Best Practice cho RBAC

## Principle of Least Privilege

Chỉ cấp quyền tối thiểu cần thiết.

Không nên:

```text
Developer -> Owner -> Entire Subscription
```

Nếu developer chỉ cần quản lý Dev Resource Group thì nên:

```text
Developer Group
      +
Contributor
      +
Dev Resource Group
```

## Prefer Group over User

Nên:

```text
DevOps Group -> Contributor
```

thay vì:

```text
User A -> Contributor
User B -> Contributor
User C -> Contributor
```

## Separate Dev and Prod permissions

Ví dụ:

```text
DevOps-Team
|
|-- Contributor -> Dev
`-- Reader      -> Prod
```

---

# 11. Azure Subscription là gì?

Subscription là một **management + billing boundary** trong Azure.

Resources luôn nằm bên trong một subscription.

Ví dụ:

```text
Azure Tenant
|
|-- Dev Subscription
|     |-- rg-app-dev
|     `-- rg-data-dev
|
`-- Prod Subscription
      |-- rg-app-prod
      `-- rg-data-prod
```

Subscription được dùng để:

- Phân tách environment
- Phân tách team hoặc workload
- Quản lý billing
- Quản lý quota
- Quản lý RBAC
- Áp dụng Azure Policy

---

# 12. Tenant và Subscription khác nhau như thế nào?

## Tenant

Tenant thuộc Microsoft Entra ID và quản lý identity.

```text
Tenant
|
|-- Users
|-- Groups
|-- Apps
`-- Authentication
```

## Subscription

Subscription chứa Azure resources.

```text
Subscription
|
|-- Resource Groups
|-- VMs
|-- Storage Accounts
|-- VNets
`-- Databases
```

Quan hệ đơn giản:

```text
Microsoft Entra Tenant
         |
         | identities
         v
Azure Subscriptions
         |
         v
Azure Resources
```

Một tenant có thể có nhiều subscriptions.

---

# 13. Khi nào nên dùng nhiều Subscription?

Trong môi trường nhỏ:

```text
1 Subscription
|
|-- rg-dev
|-- rg-test
`-- rg-prod
```

có thể đủ.

Trong enterprise thường nên tách:

```text
Tenant
|
|-- Dev Subscription
|-- Test Subscription
|-- Prod Subscription
`-- Shared Services Subscription
```

Lợi ích:

- Tách quyền Dev và Prod
- Tách billing
- Tách quota
- Giảm blast radius
- Dễ áp dụng governance khác nhau

---

# 14. Management Group

Management Group nằm phía trên Subscription.

Mục đích là quản lý nhiều subscriptions cùng lúc.

```text
Management Group
|
|-- Dev Subscription
|-- Test Subscription
`-- Prod Subscription
```

Bạn có thể áp dụng:

- Azure Policy
- RBAC

ở Management Group và các subscription bên dưới có thể kế thừa.

Ví dụ enterprise:

```text
Tenant Root Group
|
|-- Platform
|    |-- Connectivity Subscription
|    `-- Management Subscription
|
`-- Landing Zones
     |
     |-- Dev Subscription
     `-- Prod Subscription
```

---

# 15. Governance trong Azure là gì?

Governance trả lời câu hỏi:

> **Resource trong tổ chức phải tuân theo những quy tắc nào?**

Ví dụ công ty có thể yêu cầu:

```text
Only deploy in Southeast Asia
All resources must have tags
Storage public access must be disabled
Production resources cannot be deleted easily
Only approved VM sizes can be used
```

Governance giúp Azure environment:

- Consistent
- Secure
- Compliant
- Cost controlled
- Easier to manage

---

# 16. Các công cụ Governance quan trọng

Các công cụ chính:

```text
Management Groups
Azure Policy
RBAC
Resource Locks
Tags
Budgets / Cost Management
```

---

# 17. Azure Policy

Azure Policy dùng để enforce hoặc kiểm tra các rule đối với resources.

Ví dụ:

```text
Rule:
Resources can only be created in Southeast Asia
```

Nếu user cố tạo VM ở West Europe:

```text
Create VM
Location = West Europe
        |
        v
Azure Policy
        |
        v
DENY
```

Một số use case:

- Require tags
- Allowed regions
- Allowed VM SKUs
- Require HTTPS
- Disable public access
- Require diagnostic settings

---

# 18. RBAC và Azure Policy khác nhau như thế nào?

Đây là điểm rất quan trọng.

## RBAC

RBAC hỏi:

> **Bạn có quyền làm việc này không?**

Ví dụ:

```text
User -> Contributor -> Can create VM
```

## Azure Policy

Policy hỏi:

> **VM mà bạn đang tạo có tuân thủ rule của công ty không?**

Ví dụ:

```text
Contributor wants to create VM
            |
            v
RBAC: Allowed
            |
            v
Policy checks location
            |
            v
West Europe not allowed
            |
            v
DENY
```

Do đó:

```text
RBAC   = Who can do what?
Policy = What is allowed to exist?
```

---

# 19. Tags

Tag là metadata gắn với resource.

Ví dụ:

```text
environment = production
owner       = devops-team
project     = ecommerce
cost-center = IT-001
```

Tags giúp:

- Cost tracking
- Ownership
- Automation
- Governance
- Resource organization

Azure Policy có thể bắt buộc resource phải có tag.

---

# 20. Resource Locks

Resource Lock giúp tránh xóa hoặc sửa nhầm resource quan trọng.

Hai loại phổ biến:

```text
CanNotDelete
ReadOnly
```

Ví dụ Production Database:

```text
Production Database
       |
       v
CanNotDelete Lock
       |
       v
Cannot be deleted accidentally
```

---

# 21. Cost Management và Budget

Subscription cũng là một boundary quan trọng cho cost management.

Ví dụ:

```text
Dev Subscription
Budget = $500/month

Prod Subscription
Budget = $3000/month
```

Azure có thể gửi alert khi:

```text
50% budget used
80% budget used
100% budget used
```

---

# 22. IAM + RBAC + Subscription + Governance hoạt động cùng nhau

Ví dụ công ty có Dev và Prod.

```text
Microsoft Entra ID
|
|-- DevOps Group
|-- Developer Group
`-- Admin Group
        |
        v
Management Group
        |
        |-- Dev Subscription
        |      `-- Dev Resources
        |
        `-- Prod Subscription
               `-- Prod Resources
```

RBAC:

```text
Developer Group
  Contributor -> Dev Subscription
  Reader      -> Prod Subscription

Admin Group
  Owner       -> Prod Subscription
```

Policy:

```text
Dev
- Only approved regions
- Required tags

Prod
- Only approved regions
- Public access disabled
- Required tags
- Approved VM SKUs only
```

Kết quả:

- Identity được quản lý tập trung
- User chỉ có quyền cần thiết
- Dev và Prod được phân tách
- Resources phải tuân theo company standards

---

# 23. Ví dụ thực tế

Giả sử công ty có application `shopping-app`.

Architecture:

```text
Tenant
|
`-- Landing-Zones Management Group
    |
    |-- Dev Subscription
    |     |
    |     `-- rg-shopping-dev
    |          |-- VM
    |          |-- Storage
    |          `-- Key Vault
    |
    `-- Prod Subscription
          |
          `-- rg-shopping-prod
               |-- VM
               |-- Database
               `-- Key Vault
```

Permissions:

```text
Developers
    Contributor -> rg-shopping-dev
    Reader      -> rg-shopping-prod

Production Admins
    Contributor -> rg-shopping-prod
```

Policies:

```text
All resources:
- must have environment tag
- must use approved region

Production:
- public storage disabled
- approved VM sizes only
```

Đây chính là cách IAM, RBAC, Subscription và Governance kết hợp với nhau.

---

# 24. Mối quan hệ với Azure Landing Zone

Azure Landing Zone sử dụng tất cả các khái niệm trên để tạo một Azure environment chuẩn cho enterprise.

```text
Azure Landing Zone
|
|-- Identity
|     `-- Entra ID
|
|-- Access Control
|     `-- RBAC
|
|-- Organization
|     |-- Management Groups
|     `-- Subscriptions
|
|-- Governance
|     |-- Azure Policy
|     |-- Tags
|     `-- Resource Locks
|
|-- Networking
|
|-- Security
|
`-- Monitoring
```

Có thể hiểu:

> **Landing Zone là cách tổ chức kết hợp Identity, RBAC, Subscription, Networking, Security và Governance thành một nền tảng Azure chuẩn để các team deploy application.**

---

# 25. Cheat Sheet

## IAM

```text
Question: Who are you?

Main service:
Microsoft Entra ID

Objects:
User
Group
Service Principal
Managed Identity
```

## RBAC

```text
Question:
Who can do what and where?

Formula:
Principal + Role + Scope = Access
```

## Subscription

```text
Purpose:
Resource boundary
Billing boundary
RBAC boundary
Quota boundary
Governance boundary
```

## Management Group

```text
Purpose:
Organize multiple subscriptions
Apply RBAC and Policy at scale
```

## Governance

```text
Question:
What rules must resources follow?

Main tools:
Azure Policy
Management Groups
RBAC
Tags
Resource Locks
Cost Management
```

---

# 26. 5 câu cần nhớ

Nếu chỉ nhớ 5 câu về phần này, hãy nhớ:

1. **Entra ID quản lý identity.**
2. **RBAC quyết định ai được làm gì và ở đâu.**
3. **Principal + Role + Scope = Role Assignment / Access.**
4. **Subscription chứa resources và là boundary cho management, billing và access.**
5. **Governance dùng Policy, Management Group, Tags, Locks và RBAC để enforce company standards.**

---

# 27. Flow học Azure nên nhớ

```text
Microsoft Entra ID
      |
      v
Users / Groups / Service Principals / Managed Identities
      |
      v
Authentication
      |
      v
RBAC
      |
      v
Management Groups
      |
      v
Subscriptions
      |
      v
Resource Groups
      |
      v
Resources
      |
      v
Azure Policy / Governance
      |
      v
Azure Landing Zone
```

Nếu hiểu được flow này, bạn đã có nền tảng rất tốt để tiếp tục học **Azure architecture, Landing Zone, networking, security và Terraform**.
