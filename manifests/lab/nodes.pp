## nodes.pp ##
node "e1lab1", "e1lab2", "e1lab3" {
  include ntp
  # or:
  # class { "ntp": }
}
