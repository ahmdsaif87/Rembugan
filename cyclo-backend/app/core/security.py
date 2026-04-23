import os
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import firebase_admin
from firebase_admin import credentials, auth

security = HTTPBearer()

def setup_firebase():
    if not firebase_admin._apps:
        current_dir = os.path.dirname(os.path.abspath(__file__))
        
        root_dir = os.path.dirname(os.path.dirname(current_dir))
        
        cred_path = os.path.join(root_dir, "firebase-admin.json")
        
        if not os.path.exists(cred_path):
            raise FileNotFoundError(f"Gawat! File Firebase tidak ditemukan di: {cred_path}")

        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)

def verify_firebase_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token Firebase tidak valid atau kadaluarsa",
        )