importScripts('https://www.gstatic.com/firebasejs/10.15.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.15.0/firebase-messaging-compat.js');

firebase.initializeApp({
	apiKey: 'AIzaSyDg9cn4F1t3dxicgR44qRN3oDbUCud-dGE',
	authDomain: 'retaillift-ed290.firebaseapp.com',
	projectId: 'retaillift-ed290',
	storageBucket: 'retaillift-ed290.firebasestorage.app',
	messagingSenderId: '334937589408',
	appId: '1:334937589408:web:0737a2ed5a209a23886bc5',
	measurementId: 'G-LDLHRE1PQY',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
	const notification = payload.notification || {};
	const title = notification.title || 'RetailLift Alert';
	const options = {
		body: notification.body || 'New alert received.',
		icon: '/icons/Icon-192.png',
	};

	self.registration.showNotification(title, options);
});
