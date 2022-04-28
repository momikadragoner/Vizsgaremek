using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class ProductMaterial
    {
        public int ProductMaterialId { get; set; }
        public int MaterialId { get; set; }
        public int ProductId { get; set; }

        public virtual Material Material { get; set; }
        public virtual Product Product { get; set; }
    }
}
