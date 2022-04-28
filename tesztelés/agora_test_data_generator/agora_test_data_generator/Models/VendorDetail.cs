using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class VendorDetail
    {
        public int VendorDetailId { get; set; }
        public int MemberId { get; set; }
        public string CompanyName { get; set; }
        public string SiteLocation { get; set; }
        public string Website { get; set; }
        public bool TakesCustomOrders { get; set; }

        public virtual Member Member { get; set; }
    }
}
