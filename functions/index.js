const {onDocumentCreated, onDocumentUpdated} = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
admin.initializeApp();

// إشعار الفني بحجز جديد
exports.notifyTechnicianOnBooking = onDocumentCreated('bookings/{bookingId}', async (event) => {
  const data = event.data.data();
  const techId = data.technicianId;
  const techDoc = await admin.firestore().collection('technicians').doc(techId).get();
  const token = techDoc.data()?.fcmToken;
  if (!token) return;
  await admin.messaging().send({
    token,
    notification: {
      title: 'حجز جديد: ' + (data.serviceName || ''),
      body: (data.clientName || 'عميل') + ' - ' + (data.address || ''),
    },
    data: {bookingId: event.params.bookingId, type: 'new_booking'},
  });
});

// إشعار العميل بتغيّر الحالة
exports.notifyClientOnStatus = onDocumentUpdated('bookings/{bookingId}', async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (before.status === after.status) return;
  const labels = {pending: 'بانتظار القبول', accepted: 'مقبول', in_progress: 'جارٍ التنفيذ', completed: 'مكتمل', cancelled: 'ملغي'};
  const clientDoc = await admin.firestore().collection('users').doc(after.clientId).get();
  const token = clientDoc.data()?.fcmToken;
  if (!token) return;
  await admin.messaging().send({
    token,
    notification: {
      title: 'تحديث الحجز: ' + (after.serviceName || ''),
      body: 'الحالة الجديدة: ' + (labels[after.status] || after.status),
    },
    data: {bookingId: event.params.bookingId, type: 'status_change'},
  });
});
