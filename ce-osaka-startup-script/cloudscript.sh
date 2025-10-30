gcloud compute instances create instance-osaka-nodejs \
    --project=driven-manifest-475504-v0 \
    --zone=asia-northeast2-c \
    --machine-type=e2-micro \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --metadata=enable-osconfig=TRUE,startup-script=SCRIPT_SCRIPT,ssh-keys=erikestrada37:ssh-ed25519\ \
AAAAC3NzaC1lZDI1NTE5AAAAIBq\+yvnhUVnaOu3GHtWO51lxF9MNmeJiIxbf7Qfme8Cq\ erikestrada37@outlook.com \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=674394304675-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
    --tags=http-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=instance-osaka-nodejs,image=projects/debian-cloud/global/images/debian-12-bookworm-v20251014,mode=rw,size=10,type=pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ops-agent-policy=v2-x86-template-1-4-0,goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any \
&& \
printf 'agentsRule:\n  packageState: installed\n  version: latest\ninstanceFilter:\n  inclusionLabels:\n  - labels:\n      goog-ops-agent-policy: v2-x86-template-1-4-0\n' > config.yaml \
&& \
gcloud compute instances ops-agents policies create goog-ops-agent-v2-x86-template-1-4-0-asia-northeast2-c \
    --project=driven-manifest-475504-v0 \
    --zone=asia-northeast2-c \
    --file=config.yaml