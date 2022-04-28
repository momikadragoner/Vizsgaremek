using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class Material
    {
        public Material()
        {
            ProductMaterials = new HashSet<ProductMaterial>();
        }

        public int MaterialId { get; set; }
        public string MaterialName { get; set; }

        public virtual ICollection<ProductMaterial> ProductMaterials { get; set; }
    }
}
