/*
 * Copyright 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "random_id" "default" {
  byte_length = 2
}

resource "google_compute_forwarding_rule" "default" {
  project               = "${var.project}"
  name                  = "${var.name}-${lower(var.lb_protocol)}-${var.network}-${random_id.default.hex}"
  target                = "${element(concat(google_compute_target_pool.default_http.*.self_link, google_compute_target_pool.default_non_http.*.self_link), 0)}"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "${var.service_port}"
  ip_protocol           = "${replace(upper(var.lb_protocol),"HTTP","") != var.lb_protocol ? "TCP" : upper(var.lb_protocol)}"
  ip_address            = "${var.ip_address}"

  lifecycle = {
    create_before_destroy = true
  }
}

resource "google_compute_target_pool" "default_non_http" {
  count            = "${replace(lower(var.lb_protocol), "http", "") == lower(var.lb_protocol) ? 1 : 0}"
  project          = "${var.project}"
  name             = "${var.name}-${lower(var.lb_protocol)}-${var.network}-${random_id.default.hex}"
  region           = "${var.region}"
  session_affinity = "${var.session_affinity}"

  lifecycle = {
    create_before_destroy = true
  }
}

resource "google_compute_target_pool" "default_http" {
  count            = "${replace(lower(var.lb_protocol), "http", "") == lower(var.lb_protocol) ? 0 : 1}"
  project          = "${var.project}"
  name             = "${var.name}-http-${var.network}-${random_id.default.hex}"
  region           = "${var.region}"
  session_affinity = "${var.session_affinity}"

  health_checks = ["${google_compute_http_health_check.default.name}"]

  lifecycle = {
    create_before_destroy = true
  }
}

resource "google_compute_http_health_check" "default" {
  count        = "${lower(var.lb_protocol) == "http" ? 1 : 0}"
  project      = "${var.project}"
  name         = "${var.name}-${var.network}-http-hc-${random_id.default.hex}"
  request_path = "/"
  port         = "${var.service_port}"
}

resource "google_compute_firewall" "default-lb-fw" {
  project = "${var.firewall_project == "" ? var.project : var.firewall_project}"
  name    = "${var.name}-${lower(var.lb_protocol)}-${var.network}-fw-${random_id.default.hex}"
  network = "${var.network}"

  allow {
    protocol = "${replace(lower(var.lb_protocol), "http", "") == lower(var.lb_protocol) ? lower(var.lb_protocol) : "tcp"}"
    ports    = ["${var.service_port}"]
  }

  source_ranges = ["${var.source_ranges}"]
  target_tags   = ["${var.target_tags}"]
}
