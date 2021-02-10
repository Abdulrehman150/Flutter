import { snapshotConstructor } from "firebase-functions/lib/providers/firestore";

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// export const onConversationCreated = functions.firestore.document("Conversations/{conversationID}").onCreate((snapshot: { data: () => any; }, context: { params: { conversationID: any; }; }) => {
//     let data = snapshot.data();
//     let conversationID = context.params.conversationID;
//     if (data) {
//         let members = data.members;
//         for(let index = 0; index < members.length; index++) {
//             let currentUserID = members[index];
//             let remainingUserIDs = members.filter((u: any) => u !== currentUserID);
//             remainingUserIDs.forEach((m: any) => {
//                 return admin.firestore().collection("Users").doc(m).get().then((_doc: { data: () => any; }) => {
//                     let userData = _doc.data();
//                     if (userData) {
//                         return admin.firestore().collection("Users").doc(currentUserID).collection("Conversations").doc(m).create({
//                             "conversationID": conversationID,
//                             "image": userData.image,
//                             "name": userData.name,
//                             "unseenCount": 0,
//                         });
//                     }
//                     return null;
//                 }).catch(() => { return null; });
//             });
//         }
//     }
//     return null;
// });

export const onConversationUpdated = functions.firestore.document("Conversations/{conversationID}").onUpdate((change: { after: { data: () => any; }; } | null | undefined, context: any) => {
    let data = change?.after.data();
    if (data) {
        let members = data.members;
        let lastMessage = data.messages[data.messages.length - 1];
        for (let index = 0; index < members.length; index++) {
            let currentUserID = members[index];
            let remainingUserIDs = members.filter((u: any) => u !== currentUserID);
            remainingUserIDs.forEach((u: any) => {
                return admin.firestore().collection("Users").doc(currentUserID).collection("Conversations").doc(u).update({
                    "lastMessage": lastMessage.message,
                    "timestamp": lastMessage.timestamp,
                    "type": lastMessage.type,
                    "unseenCount": admin.firestore.FieldValue.increment(1),
                });
            });
        }
    }
    return null;
});

exports.sendNotification = functions.firestore
.document('Conversations/{conversationID}/Messages/{messageID}')
.onCreate(async( snapshot: { data: () => any; },context: { params: { conversationID: any; messageID: any; }; }) =>{
 try{  

    const notificationDocument = snapshot.data();
    const uid1 = context.params.conversationID;
    const uid = context.params.messageID;
    var token = '';

    const notificationMessage = notificationDocument.message;

    const userDoc = await admin.firestore().collection("Conversations").doc(uid1).collection("Messages").doc(uid).get();
    const senderID = userDoc.data().senderID;
    const senderData = await admin.firestore().collection("Users").doc(senderID).get();
    const notificationTitle = senderData.data().name;


    const receiverID = userDoc.data().receiverID;
    const tokenId =await admin.firestore().collection("Users").doc(receiverID).get();
    token = tokenId.data().fcmToken;

    const message = {
        

        "notification" : {
            title: notificationTitle,
            body: notificationMessage,
            sound: 'default',
        },
        
        
    };

    return admin.messaging().sendToDevice(token, message )
 }
    catch(e){
        console.log(e)

    }
});

