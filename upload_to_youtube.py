#!/usr/bin/env python3
import os
import glob
import json
import googleapiclient.discovery
import googleapiclient.errors
from googleapiclient.http import MediaFileUpload
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request

def upload_to_youtube():
    # Get client secrets from the environment
    client_secret_path = "client_secret.json"
    
    # Load the client secret
    with open(client_secret_path, "r") as f:
        client_info = json.load(f)
    
    client_id = client_info["web"]["client_id"]
    client_secret = client_info["web"]["client_secret"]
    
    # Get refresh token from environment variable
    refresh_token = os.environ.get("YOUTUBE_REFRESH_TOKEN")
    
    if not refresh_token:
        print("⚠️ No YOUTUBE_REFRESH_TOKEN found in environment variables!")
        print("Please run the one-time setup workflow first.")
        return
    
    # Create credentials using the refresh token
    credentials = Credentials(
        None,  # No access token initially
        refresh_token=refresh_token,
        token_uri="https://oauth2.googleapis.com/token",
        client_id=client_id,
        client_secret=client_secret,
        scopes=["https://www.googleapis.com/auth/youtube.upload"]
    )
    
    # Refresh the access token
    credentials.refresh(Request())
    
    # Create the YouTube API client
    youtube = googleapiclient.discovery.build("youtube", "v3", credentials=credentials)
    
    # Find videos to upload
    video_files = glob.glob("videos/generated/*.mp4")
    if not video_files:
        print("No video files found to upload!")
        return
    
    # Upload each video
    for video_file in video_files:
        try:
            video_title = os.path.basename(video_file).split(".")[0]
            
            # Prepare the request body
            body = {
                "snippet": {
                    "title": video_title,
                    "description": f"Video automatically generated and uploaded by GitHub Actions: {video_title}",
                    "tags": ["automated", "github-actions"],
                    "categoryId": "22"  # People & Blogs category
                },
                "status": {
                    "privacyStatus": "unlisted",
                    "selfDeclaredMadeForKids": False
                }
            }
            
            # Create the upload request
            media = MediaFileUpload(video_file, chunksize=1024*1024, resumable=True)
            request = youtube.videos().insert(
                part=",".join(body.keys()),
                body=body,
                media_body=media
            )
            
            # Execute the upload in chunks
            print(f"Uploading {video_file}...")
            response = None
            while response is None:
                status, response = request.next_chunk()
                if status:
                    print(f"Uploaded {int(status.progress() * 100)}%")
            
            print(f"Upload complete! Video ID: {response['id']}")
            
        except Exception as e:
            print(f"Error uploading {video_file}: {str(e)}")

if __name__ == "__main__":
    upload_to_youtube()
