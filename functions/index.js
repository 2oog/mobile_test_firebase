const { onDocumentCreated, onDocumentUpdated, onDocumentDeleted } =
  require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

function buildNotification(changeType, collection, docId) {
  const appName = "Items Demo"; // your app title
  const title = `${appName}: Firestore ${changeType}`;
  const body = `${collection}: ${docId}`;
  return { title, body };
}

// CREATE trigger
exports.onItemCreated = onDocumentCreated("items/{itemId}", async (event) => {
  const itemId = event.params.itemId;
  const notif = buildNotification("CREATE", "Item", itemId);

  await admin.messaging().send({
    topic: "firestore_changes",
    notification: {
      title: notif.title,
      body: notif.body,
    },
    data: {
      changeType: "CREATE",
      collection: "items",
      docId: itemId,
    },
  });

  logger.info("Sent CREATE notification for", itemId);
});

// UPDATE trigger
exports.onItemUpdated = onDocumentUpdated("items/{itemId}", async (event) => {
  const itemId = event.params.itemId;
  const notif = buildNotification("UPDATE", "Item", itemId);

  await admin.messaging().send({
    topic: "firestore_changes",
    notification: {
      title: notif.title,
      body: notif.body,
    },
    data: {
      changeType: "UPDATE",
      collection: "items",
      docId: itemId,
    },
  });

  logger.info("Sent UPDATE notification for", itemId);
});

// DELETE trigger
exports.onItemDeleted = onDocumentDeleted("items/{itemId}", async (event) => {
  const itemId = event.params.itemId;
  const notif = buildNotification("DELETE", "Item", itemId);

  await admin.messaging().send({
    topic: "firestore_changes",
    notification: {
      title: notif.title,
      body: notif.body,
    },
    data: {
      changeType: "DELETE",
      collection: "items",
      docId: itemId,
    },
  });

  logger.info("Sent DELETE notification for", itemId);
});
