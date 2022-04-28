using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class WishList
    {
        public int WishListId { get; set; }
        public int ProductId { get; set; }
        public int MemberId { get; set; }
        public DateTime? AddedAt { get; set; }

        public virtual Member Member { get; set; }
        public virtual Product Product { get; set; }
    }
}
