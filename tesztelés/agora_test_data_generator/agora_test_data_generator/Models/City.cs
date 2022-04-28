using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class City
    {
        public int CityId { get; set; }
        public string CityName { get; set; }
        public string PostalCode { get; set; }
        public int RegionId { get; set; }

        public virtual Region Region { get; set; }
    }
}
