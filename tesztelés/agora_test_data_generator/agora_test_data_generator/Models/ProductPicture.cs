using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class ProductPicture
    {
        public int ProductPictureId { get; set; }
        public int ProductId { get; set; }
        public string ResourceName { get; set; }
        public string ResourceLink { get; set; }
        public bool? IsThumbnail { get; set; }

        public virtual Product Product { get; set; }
    }
}
