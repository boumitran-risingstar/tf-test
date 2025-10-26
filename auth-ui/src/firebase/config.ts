
import { initializeApp, getApps, getApp } from "firebase/app";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyBWEwPAbYKc_92cmtyRvTqAmC4boRtR3dc",
  authDomain: "tf-test-476002.firebaseapp.com",
  projectId: "tf-test-476002",
  storageBucket: "tf-test-476002.appspot.com",
  messagingSenderId: "731717657303",
  appId: "1:731717657303:web:594b0fd90f1d0cf9b30692"
};

// Initialize Firebase
const app = !getApps().length ? initializeApp(firebaseConfig) : getApp();
const auth = getAuth(app);

export { auth };
