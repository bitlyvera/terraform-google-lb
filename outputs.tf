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

output target_pool {
  description = "The `self_link` to the target pool resource created."
  value       = "${element(coalescelist(google_compute_target_pool.default_http.*.self_link,google_compute_target_pool.default_non_http.*.self_link),0)}"
}

output external_ip {
  description = "The external ip address of the forwarding rule."
  value       = "${google_compute_forwarding_rule.default.ip_address}"
}
