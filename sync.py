import os, sys, shutil
from huggingface_hub import hf_hub_download, HfApi

token = os.environ.get("HF_TOKEN")
repo_id = os.environ.get("HF_REPO_ID")
db_path = os.environ.get("DB_PATH", "/data/storage.sqlite")
action = sys.argv[1] if len(sys.argv) > 1 else ""

if not token or not repo_id:
    print("==> HF_TOKEN or HF_REPO_ID missing. Skipping sync.")
    sys.exit(0)

api = HfApi()

if action == "restore":
    try:
        os.makedirs(os.path.dirname(db_path), exist_ok=True)
        file = hf_hub_download(repo_id=repo_id, repo_type="dataset", filename="storage.sqlite", token=token)
        shutil.copy(file, db_path)
        print("==> Database successfully restored from Hugging Face.")
    except Exception as e:
        print(f"==> No existing remote database snapshot found ({e}). Initializing fresh instance.")

elif action == "backup":
    if os.path.exists(db_path):
        try:
            # Ensure dataset exists before uploading
            api.create_repo(repo_id=repo_id, repo_type="dataset", private=True, exist_ok=True, token=token)
            
            api.upload_file(
                path_or_fileobj=db_path,
                path_in_repo="storage.sqlite",
                repo_id=repo_id,
                repo_type="dataset",
                token=token
            )
            print("==> Database snapshot successfully backed up to Hugging Face.")
        except Exception as e:
            print(f"==> Backup error: {e}")
