const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initiliazeApp();

exports.sendNotificationOnStatusChange = functions.firestore
    .document('order/{userId}/pesanan/{orderId}')
    .onUpdate(async (change, context) => {
        const before = change.before.data();
        const after = change.after.data();

        if (before.status !== after.status && after.status === 'Menunggu Konfirmasi') {
            const payload = {
                notification: {
                    title: 'Status Pesanan',
                    body: `Status pesanan Anda telah berubah menjadi ${after.status}`
                }
            };

            const userId = context.params.userId;
            const userDoc = await admin.firestore().collection('users').doc(userId).get();
            const fcmToken = userDoc.data().fcmToken;

            if (fcmToken) {
                await admin.messaging().sendToDevice(fcmToken, payload);
            }
        }
    });


