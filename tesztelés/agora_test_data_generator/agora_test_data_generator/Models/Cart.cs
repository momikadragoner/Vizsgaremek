using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class Cart
    {
        public Cart()
        {
            CartProducts = new HashSet<CartProduct>();
        }

        public int CartId { get; set; }
        public int MemberId { get; set; }
        public int? ShippingAddressId { get; set; }
        public int? SumPrice { get; set; }
        public string Status { get; set; }

        public virtual Member Member { get; set; }
        public virtual ShippingAddress ShippingAddress { get; set; }
        public virtual ICollection<CartProduct> CartProducts { get; set; }
    }
}
