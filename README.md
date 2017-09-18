# Office365 Functions

This is a library containing numerous functions (sub resource) which can be directly implemented as Functions in Azure.

### Out of Office

Resource name: `auto-reply`  
Path: `ps/auto-reply`  
Actions: `enable` / `disable`

Payload:
```json
{
	"email": "email@domain.com",
	"message": "Out of Office message",
	"action": "enable"
}
```

Response:
```json
{
	"email": "email@domain.com",
	"message": "Out of Office message",
	"detail": "Auto reply enabled.",
	"status": 1
}
```

Status codes

| Code  | Description    |
| ----  | -------------- |
| **1** | Enabled      |
| **2** | Disabled     |

### Shared Mailbox

Resource name: `mailbox`  
Path: `ps/mailbox`  


Payload:
```json
{
	"email": "email@domain.com",
	"name": "Name of your mailbox",
	"owner": "owner@domain.com"
}
```

Response:
```json
{
	"email": "email@domain.com",
	"status": 1,
	"detail": "Mailbox created.",
	"name": "Name of your mailbox",
	"owner": "owner@domain.com"
}
```

Status codes

| Code  | Description        |
| ----  | --------------     |
| **1** | Mailbox created  |
| **2** | Mailbox exits    |
| **3** | ACL group exists |

### Distribution List

Resource name: `dl`  
Path: `ps/dl`  


Payload:
```json
{
	"email": "email@domain.com",
	"name": "Name of your distribution list",
	"owner": "owner@domain.com"
}
```

Response:
```json
{
	"email": "email@domain.com",
	"status": 1,
	"detail": "DL created.",
	"name": "Name of your distribution list",
	"owner": "owner@domain.com"
}
```

Status codes

| Code  | Description    |
| ----  | -------------- |
| **1** | DL created   |
| **2** | DL exits     |

### Multi Factor Authentication (MFA) reset

Resource name: `mfa`  
Path: `ps/mfa`  
Actions: `enable` / `disable` / `reset`

Payload:
```json
{
	"email": "email@domain.com",
	"action": "reset"
}
```

Response:
```json
{
	"email": "email@domain.com",
	"detail": "MFA Reset completed.",
	"status": 3
}
```

Status codes

| Code  | Description               |
| ----  | --------------            |
| **1** | Enabled                   |
| **2** | Disabled                  |
| **3** | Reset                     |
| **4** | Others (Check description)|