using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class ShippingAddress
    {
        public ShippingAddress()
        {
            Carts = new HashSet<Cart>();
        }

        public int ShippingAddressId { get; set; }
        public int? MemberId { get; set; }
        public string Name { get; set; }
        public string Phone { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public string Country { get; set; }
        public string Region { get; set; }
        public string City { get; set; }
        public string StreetAdress { get; set; }
        public string PostalCode { get; set; }

        public virtual Member Member { get; set; }
        public virtual ICollection<Cart> Carts { get; set; }
    }
}
