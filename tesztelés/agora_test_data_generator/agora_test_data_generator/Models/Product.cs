using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class Product
    {
        public Product()
        {
            CartProducts = new HashSet<CartProduct>();
            ProductMaterials = new HashSet<ProductMaterial>();
            ProductPictures = new HashSet<ProductPicture>();
            ProductTags = new HashSet<ProductTag>();
            ReviewVotes = new HashSet<ReviewVote>();
            Reviews = new HashSet<Review>();
            WishLists = new HashSet<WishList>();
        }

        public int ProductId { get; set; }
        public string Name { get; set; }
        public int? Price { get; set; }
        public string Description { get; set; }
        public int? Inventory { get; set; }
        public string Delivery { get; set; }
        public string Category { get; set; }
        public double? Rating { get; set; }
        public int? VendorId { get; set; }
        public int? Discount { get; set; }
        public bool? IsPublished { get; set; }
        public bool? IsRemoved { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? LastUpdatedAt { get; set; }
        public DateTime? PublishedAt { get; set; }

        public virtual Member Vendor { get; set; }
        public virtual ICollection<CartProduct> CartProducts { get; set; }
        public virtual ICollection<ProductMaterial> ProductMaterials { get; set; }
        public virtual ICollection<ProductPicture> ProductPictures { get; set; }
        public virtual ICollection<ProductTag> ProductTags { get; set; }
        public virtual ICollection<ReviewVote> ReviewVotes { get; set; }
        public virtual ICollection<Review> Reviews { get; set; }
        public virtual ICollection<WishList> WishLists { get; set; }
    }
}
