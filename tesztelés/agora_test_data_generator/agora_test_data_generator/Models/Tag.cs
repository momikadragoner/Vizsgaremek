using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class Tag
    {
        public Tag()
        {
            ProductTags = new HashSet<ProductTag>();
        }

        public int TagId { get; set; }
        public string TagName { get; set; }

        public virtual ICollection<ProductTag> ProductTags { get; set; }
    }
}
