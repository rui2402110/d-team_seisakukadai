import boto3
from botocore.exceptions import ClientError
region = 'us-east-1' 
s3 = boto3.client('s3', region_name=region)

bucket_names = [
    'dteam-posts-bucket',   # 投稿用
    'dteam-works-bucket',   # 作品用
    'dteam-icons-bucket',   # アイコン用
]
for bucket_name in bucket_names:
    try:
        if region == 'us-east-1':
            response = s3.create_bucket(Bucket=bucket_name)
        else:
            response = s3.create_bucket(
                Bucket=bucket_name,
                CreateBucketConfiguration={
                    'LocationConstraint': region,
                },
            )
        print(f"成功: バケット '{bucket_name}' を作成しました。")
        
    except ClientError as e:
        print(f"失敗: バケット '{bucket_name}' の作成に失敗しました。理由: {e}")