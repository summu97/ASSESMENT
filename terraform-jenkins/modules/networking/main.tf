resource "google_project_service" "dns" {
  project = var.project_id

  service = "dns.googleapis.com"
}

resource "google_compute_network" "custom_network" {
  name           = "custom-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "jenkins-server" {
  name          = "jenkins-server-subnet"
  region        = var.jenkins-server_region
  network       = google_compute_network.custom_network.self_link
  ip_cidr_range = var.jenkins-server_cidr
}

resource "google_compute_subnetwork" "desktop-server" {
  name          = "desktop-server-subnet"
  region        = var.desktop-server_region
  network       = google_compute_network.custom_network.self_link
  ip_cidr_range = var.desktop-server_cidr
}
resource "google_compute_firewall" "jenkins-server" {
  name    = "jenkins-server-firewall"
  network = google_compute_network.custom_network.self_link

  # Allow rules
  allow {
    protocol = "tcp"
    ports    = ["22", "8080", "32768-60999", "4243"]
  }
  
  allow {
    protocol = "icmp"
  }

  target_tags = [var.jenkins-server_network_tags] # Apply to VMs with this tag
  source_ranges = ["0.0.0.0/0"]  # Allow traffic from any source
}

resource "google_compute_firewall" "desktop-server" {
  name    = "desktop-server-firewall"
  network = google_compute_network.custom_network.self_link

  # Allow rules
  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
  
  allow {
    protocol = "icmp"
  }

  target_tags = [var.desktop-server_network_tags] # Apply to VMs with this tag
  source_ranges = ["0.0.0.0/0"]  # Allow traffic from any source
}

resource "google_compute_firewall" "tomcat-server" {
  name    = "tomcat-server-firewall"
  network = google_compute_network.custom_network.self_link

  # Allow rules
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  
  allow {
    protocol = "icmp"
  }

  target_tags = [var.tomcat-server_network_tags] # Apply to VMs with this tag
  source_ranges = ["0.0.0.0/0"]  # Allow traffic from any source
}

output "network_self_link" {
  value = google_compute_network.custom_network.self_link
}

output "jenkins_subnetwork_self_link" {
  value = google_compute_subnetwork.jenkins-server.self_link
}
