#!/usr/bin/env python3
import os
import json
import sys
from google_auth_oauthlib.flow import Flow
from google.auth.transport.requests import Request

# Get the auth code from the workflow input
auth_code = os.environ.get("AUTH_CODE")
if not auth_code:
    print("::error::No authorization code provided. Please run the workflow with an auth code.")
    sys.exit(1)

# Load client secrets
with open("client_secret.json", "r") as f:
    client_config = json.load(f)

# Create a flow instance
flow = Flow.from_client_config(
    client_config,
    scopes=["https://www.googleapis.com/auth/youtube.upload"],
    redirect_uri="urn:ietf:wg:oauth:2.0:oob"
)

# Exchange auth code for credentials
try:
    flow.fetch_token(code=auth_code)
    credentials = flow.credentials
    
    # Output the refresh token
    with open("refresh_token.txt", "w") as f:
        f.write(credentials.refresh_token)
    
    print("\n========== YOUR REFRESH TOKEN ==========")
    print(credentials.refresh_token)
    print("========================================\n")
    print("Add this as a GitHub secret named YOUTUBE_REFRESH_TOKEN")
    
except Exception as e:
    print(f"::error::Failed to exchange authorization code for tokens: {str(e)}")
    sys.exit(1)
