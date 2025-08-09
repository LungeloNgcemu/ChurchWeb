importScripts('https://www.gstatic.com/firebasejs/9.9.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.9.0/firebase-messaging-compat.js');

firebase.initializeApp({
    apiKey: "AIzaSyC68W0ODoBk8taha9W08fVZcRbHUEbYUm0",
    authDomain: "churchconnect-8157d.firebaseapp.com",
    projectId: "churchconnect-8157d",
    storageBucket: "churchconnect-8157d.firebasestorage.app",
    messagingSenderId: "301652956348",
    appId: "1:301652956348:web:5773e288b7f491633e6cb9",
    measurementId: "G-6BBJLB1FXN"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(async (payload) => {
    console.log('Received background message:', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/icons/Icon-192.png',
        badge: '/icons/Icon-192.png',
        // data: payload.data,
        click_action: payload.notification.click_action,
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
}); 