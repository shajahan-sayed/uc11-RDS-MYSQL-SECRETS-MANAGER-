terraform {
   backend "s3" {
       bucket = "two-tier-backend"
       key = "terraform.tfstate"
       region = "ap-southeast-2"
    }
}

       
