variable "ResourceGroup_location" {
  default = "West Europe"
}

variable "ResourceGroup_name" {
  default = "ProjectWeek5"
}

variable "VirtualNetwork_name" {
  default = "VirtualNetwork"
}

variable "SubNet_VM" {
  default = "SubNet_VM"
}
variable "SubNet_SQL" {
  default = "SubNet_SQL"
}

variable "NetworkSecurityGroup_VM" {
  default = "NSG_VM"
}

variable "NetworkSecurityGroup_SQL" {
  default = "NSG_SQL"
}

variable "name_count" {
  default = ["server1", "server2"]
}