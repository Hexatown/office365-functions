# Office365 Functions

This is a library containing numerous functions (sub resource) which can be directly implemented as Functions in Azure.

### Out of Office

Resource name: `auto-reply`  
Path: `ps/auto-reply`  
Actions: `enable` / `disable`

Payload:
```json
{
	"email": "your-email@domain.com",
	"message": "Out of Office message",
	"action": "enable"
}
```

Response:
```json
{
	"email": "your-email@domain.com",
	"message": "Out of Office message",
	"detail": "Auto reply enabled.",
	"status": 1
}
```

Status codes

| Code | Description    |
| ---- | -------------- |
| *1*  | Enabled        |
| *2*  | Disabled       |

### Shared Mailbox

### Distribution List

### Multi Factor Authentication (MFA) reset
