# CORS وطلب OTP من الويب

## المشكلة

عند تشغيل التطبيق كـ **ويب** من `http://localhost:xxxx`، المتصفح يمنع الطلبات إلى `https://cw.abdullah9.sa` لأن الخادم لا يرسل رؤوس CORS المناسبة:

```
Access to XMLHttpRequest at 'https://cw.abdullah9.sa/auth/otp/request' from origin 'http://localhost:55458' 
has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

## الحل 1: إعداد الخادم (الحل الصحيح للإنتاج)

يجب على **الخادم** في `cw.abdullah9.sa` أن يسمح بأصول التطبيق بإرجاع الرؤوس التالية:

- في **استجابة preflight** (طلب `OPTIONS`):
  - `Access-Control-Allow-Origin`: إما `*` أو قائمة الأصول المسموحة، مثلاً:
    - للتطوير: `http://localhost:55458` أو `http://localhost:*`
    - للإنتاج: نطاق تطبيقك (مثل `https://your-app.domain.com`)
  - `Access-Control-Allow-Methods`: على الأقل `GET, POST, OPTIONS` (وأي طريقة أخرى تستخدمها الـ API)
  - `Access-Control-Allow-Headers`: على الأقل `Content-Type, Authorization`
  - `Access-Control-Max-Age`: مثلاً `86400`

- في **استجابة الطلب الفعلي** (مثل `POST /auth/otp/request`):
  - `Access-Control-Allow-Origin`: نفس القيمة المستخدمة في preflight

مثال إعداد (لخادم Node/Express):

```js
app.use((req, res, next) => {
  const allowedOrigins = [
    'http://localhost:55458',
    'http://127.0.0.1:55458',
    'https://your-production-domain.com'
  ];
  const origin = req.headers.origin;
  if (allowedOrigins.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  }
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(204);
  }
  next();
});
```

إذا كان الخادم وراء Nginx أو Cloudflare، يمكن ضبط CORS هناك بدلاً من التطبيق.

## الحل 2: التطوير المحلي فقط (تجاوز CORS في Chrome)

للتجربة المحلية **فقط** بدون تعديل الخادم، يمكن تشغيل التطبيق مع Chrome بعد تعطيل فحص أمان CORS:

```powershell
.\scripts\run_web_dev.ps1
```

أو يدوياً:

```powershell
flutter run -d chrome --web-browser-flag "--disable-web-security" --web-browser-flag "--user-data-dir=.chrome_dev_profile"
```

**تحذير:** لا تستخدم هذا الوضع لتصفح مواقع أخرى؛ مخصص فقط لتشغيل التطبيق المحلي.

## ملخص

| البيئة        | الحل المناسب                          |
|---------------|----------------------------------------|
| تطوير ويب محلي | تشغيل Chrome مع تعطيل CORS (الحل 2)   |
| إنتاج / اختبار حقيقي | إعداد CORS على خادم `cw.abdullah9.sa` (الحل 1) |
