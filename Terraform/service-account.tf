# Create a Google Cloud Service Account
resource "google_service_account" "vm-repo" {
  account_id   = "vm-account"
  display_name = "VM Account"
}

# Create a Service Account Key
resource "google_service_account_key" "vm-repo-key" {
  service_account_id = google_service_account.vm-repo.id
}

# Assign the Artifact Registry Repository Writer" role to the service account
resource "google_project_iam_member" "vm-repo-roles" {
  project = var.project_id
  count   = length(var.roles)
  role    = var.roles[count.index]
  member  = "serviceAccount:${google_service_account.vm-repo.email}"
}
