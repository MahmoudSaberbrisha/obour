# إعداد الـ API للتطبيق

## الطرق المتاحة لتشغيل التطبيق على أي هاتف

### الطريقة 1: استخدام خادم سحابي (مستوصى به)

قم بوضع عنوان خادمك السحابي في ملف `.env`:

```env
API_BASE_URL=https://your-api-domain.com
```

أو باستخدام IP عام:
```env
API_BASE_URL=https://123.456.789.0
```

### الطريقة 2: استخدام خدمة Ngrok (للاختبار السريع)

إذا كان الخادم يعمل محلياً على جهازك:

1. ثبت Ngrok: https://ngrok.com/download
2. شغل الخادم المحلي على المنفذ 5050
3. نفذ الأمر:
```bash
ngrok http 5050
```
4. ستتحصل على رابط مثل: `https://abc123.ngrok.io`
5. ضع هذا الرابط في ملف `.env`:
```env
API_BASE_URL=https://abc123.ngrok.io
```

### الطريقة 3: استخدام IP العام مع فتح المنفذ

1. احصل على IP العام لجهازك: https://whatismyipaddress.com
2. افتح المنفذ 5050 في الراوتر
3. ضع في ملف `.env`:
```env
API_BASE_URL=http://your-public-ip:5050
```

## خطوات التعديل

### 1. افتح ملف `.env` في المجلد الجذر للمشروع

### 2. غير قيمة `API_BASE_URL` إلى عنوان خادمك الفعلي

مثال:
```env
API_BASE_URL=https://api.example.com
```

### 3. أعد تشغيل التطبيق

```bash
flutter run
```

## ملاحظات مهمة

- استخدم `https://` بدلاً من `http://` للأمان
- تأكد من أن الخادم يدعم CORS
- تأكد من أن الخادم يعمل على المنفذ المحدد
- الخوادم السحابية مثل Heroku, Firebase, AWS هي الأفضل للإنتاج

## مثال على الخادمات السحابية الشائعة

- **Firebase Hosting**: `https://your-app.web.app`
- **Heroku**: `https://your-app.herokuapp.com`
- **AWS**: `https://your-api.execute-api.us-east-1.amazonaws.com`
- **Render**: `https://your-app.onrender.com`

