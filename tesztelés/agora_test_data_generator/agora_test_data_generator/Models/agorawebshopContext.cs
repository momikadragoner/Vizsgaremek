using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class agorawebshopContext : DbContext
    {
        public agorawebshopContext()
        {
        }

        public agorawebshopContext(DbContextOptions<agorawebshopContext> options)
            : base(options)
        {
        }

        public virtual DbSet<Cart> Carts { get; set; }
        public virtual DbSet<CartProduct> CartProducts { get; set; }
        public virtual DbSet<City> Cities { get; set; }
        public virtual DbSet<FollowerRelation> FollowerRelations { get; set; }
        public virtual DbSet<Material> Materials { get; set; }
        public virtual DbSet<Member> Members { get; set; }
        public virtual DbSet<Message> Messages { get; set; }
        public virtual DbSet<Notification> Notifications { get; set; }
        public virtual DbSet<Product> Products { get; set; }
        public virtual DbSet<ProductMaterial> ProductMaterials { get; set; }
        public virtual DbSet<ProductPicture> ProductPictures { get; set; }
        public virtual DbSet<ProductTag> ProductTags { get; set; }
        public virtual DbSet<Region> Regions { get; set; }
        public virtual DbSet<Review> Reviews { get; set; }
        public virtual DbSet<ReviewVote> ReviewVotes { get; set; }
        public virtual DbSet<Session> Sessions { get; set; }
        public virtual DbSet<ShippingAddress> ShippingAddresses { get; set; }
        public virtual DbSet<Tag> Tags { get; set; }
        public virtual DbSet<VendorDetail> VendorDetails { get; set; }
        public virtual DbSet<WishList> WishLists { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
                optionsBuilder.UseMySql("server=localhost;user=root;database=agora-webshop", Microsoft.EntityFrameworkCore.ServerVersion.Parse("10.4.24-mariadb"));
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.HasCharSet("utf8mb4")
                .UseCollation("utf8mb4_hungarian_ci");

            modelBuilder.Entity<Cart>(entity =>
            {
                entity.ToTable("cart");

                entity.HasIndex(e => e.MemberId, "member_id");

                entity.HasIndex(e => e.ShippingAddressId, "shipping_address_id");

                entity.Property(e => e.CartId)
                    .HasColumnType("int(11)")
                    .HasColumnName("cart_id");

                entity.Property(e => e.MemberId)
                    .HasColumnType("int(11)")
                    .HasColumnName("member_id");

                entity.Property(e => e.ShippingAddressId)
                    .HasColumnType("int(11)")
                    .HasColumnName("shipping_address_id");

                entity.Property(e => e.Status)
                    .HasMaxLength(50)
                    .HasColumnName("status");

                entity.Property(e => e.SumPrice)
                    .HasColumnType("int(11)")
                    .HasColumnName("sum_price");

                entity.HasOne(d => d.Member)
                    .WithMany(p => p.Carts)
                    .HasForeignKey(d => d.MemberId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("cart_ibfk_2");

                entity.HasOne(d => d.ShippingAddress)
                    .WithMany(p => p.Carts)
                    .HasForeignKey(d => d.ShippingAddressId)
                    .HasConstraintName("cart_ibfk_1");
            });

            modelBuilder.Entity<CartProduct>(entity =>
            {
                entity.ToTable("cart_product");

                entity.HasIndex(e => e.CartId, "cart_id");

                entity.HasIndex(e => e.ProductId, "product_id");

                entity.Property(e => e.CartProductId)
                    .HasColumnType("int(11)")
                    .HasColumnName("cart_product_id");

                entity.Property(e => e.Amount)
                    .HasColumnType("int(11)")
                    .HasColumnName("amount");

                entity.Property(e => e.CartId)
                    .HasColumnType("int(11)")
                    .HasColumnName("cart_id");

                entity.Property(e => e.ProductId)
                    .HasColumnType("int(11)")
                    .HasColumnName("product_id");

                entity.Property(e => e.Status)
                    .HasMaxLength(50)
                    .HasColumnName("status");

                entity.HasOne(d => d.Cart)
                    .WithMany(p => p.CartProducts)
                    .HasForeignKey(d => d.CartId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("cart_product_ibfk_2");

                entity.HasOne(d => d.Product)
                    .WithMany(p => p.CartProducts)
                    .HasForeignKey(d => d.ProductId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("cart_product_ibfk_1");
            });

            modelBuilder.Entity<City>(entity =>
            {
                entity.ToTable("city");

                entity.HasIndex(e => e.RegionId, "region_id");

                entity.Property(e => e.CityId)
                    .HasColumnType("int(11)")
                    .HasColumnName("city_id");

                entity.Property(e => e.CityName)
                    .IsRequired()
                    .HasMaxLength(50)
                    .HasColumnName("city_name");

                entity.Property(e => e.PostalCode)
                    .IsRequired()
                    .HasMaxLength(10)
                    .HasColumnName("postal_code");

                entity.Property(e => e.RegionId)
                    .HasColumnType("int(11)")
                    .HasColumnName("region_id");

                entity.HasOne(d => d.Region)
                    .WithMany(p => p.Cities)
                    .HasForeignKey(d => d.RegionId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("city_ibfk_1");
            });

            modelBuilder.Entity<FollowerRelation>(entity =>
            {
                entity.HasKey(e => new { e.FollowerId, e.FollowingId })
                    .HasName("PRIMARY")
                    .HasAnnotation("MySql:IndexPrefixLength", new[] { 0, 0 });

                entity.ToTable("follower_relations");

                entity.HasIndex(e => e.FollowingId, "following_id");

                entity.Property(e => e.FollowerId)
                    .HasColumnType("int(11)")
                    .HasColumnName("follower_id");

                entity.Property(e => e.FollowingId)
                    .HasColumnType("int(11)")
                    .HasColumnName("following_id");

                entity.HasOne(d => d.Follower)
                    .WithMany(p => p.FollowerRelationFollowers)
                    .HasForeignKey(d => d.FollowerId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("follower_relations_ibfk_1");

                entity.HasOne(d => d.Following)
                    .WithMany(p => p.FollowerRelationFollowings)
                    .HasForeignKey(d => d.FollowingId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("follower_relations_ibfk_2");
            });

            modelBuilder.Entity<Material>(entity =>
            {
                entity.ToTable("material");

                entity.Property(e => e.MaterialId)
                    .HasColumnType("int(11)")
                    .HasColumnName("material_id");

                entity.Property(e => e.MaterialName)
                    .HasMaxLength(50)
                    .HasColumnName("material_name");
            });

            modelBuilder.Entity<Member>(entity =>
            {
                entity.ToTable("member");

                entity.Property(e => e.MemberId)
                    .HasColumnType("int(11)")
                    .HasColumnName("member_id");

                entity.Property(e => e.About)
                    .HasColumnType("text")
                    .HasColumnName("about");

                entity.Property(e => e.Email)
                    .IsRequired()
                    .HasMaxLength(320)
                    .HasColumnName("email");

                entity.Property(e => e.FirstName)
                    .HasMaxLength(50)
                    .HasColumnName("first_name");

                entity.Property(e => e.HeaderPictureLink)
                    .HasMaxLength(200)
                    .HasColumnName("header_picture_link");

                entity.Property(e => e.IsAdmin).HasColumnName("is_admin");

                entity.Property(e => e.IsVendor).HasColumnName("is_vendor");

                entity.Property(e => e.LastLogin)
                    .HasColumnType("datetime")
                    .HasColumnName("last_login");

                entity.Property(e => e.LastName)
                    .HasMaxLength(50)
                    .HasColumnName("last_name");

                entity.Property(e => e.Password)
                    .IsRequired()
                    .HasMaxLength(64)
                    .HasColumnName("password");

                entity.Property(e => e.Phone)
                    .HasMaxLength(15)
                    .HasColumnName("phone");

                entity.Property(e => e.ProfilePictureLink)
                    .HasMaxLength(200)
                    .HasColumnName("profile_picture_link");

                entity.Property(e => e.RegisteredAt)
                    .HasColumnType("datetime")
                    .HasColumnName("registered_at");
            });

            modelBuilder.Entity<Message>(entity =>
            {
                entity.ToTable("message");

                entity.HasIndex(e => e.ReciverId, "reciver_id");

                entity.HasIndex(e => e.SenderId, "sender_id");

                entity.Property(e => e.MessageId)
                    .HasColumnType("int(11)")
                    .HasColumnName("message_id");

                entity.Property(e => e.Message1)
                    .HasMaxLength(255)
                    .HasColumnName("message");

                entity.Property(e => e.ReciverId)
                    .HasColumnType("int(11)")
                    .HasColumnName("reciver_id");

                entity.Property(e => e.SenderId)
                    .HasColumnType("int(11)")
                    .HasColumnName("sender_id");

                entity.Property(e => e.SentAt)
                    .HasColumnType("datetime")
                    .HasColumnName("sent_at");

                entity.HasOne(d => d.Reciver)
                    .WithMany(p => p.MessageRecivers)
                    .HasForeignKey(d => d.ReciverId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("message_ibfk_2");

                entity.HasOne(d => d.Sender)
                    .WithMany(p => p.MessageSenders)
                    .HasForeignKey(d => d.SenderId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("message_ibfk_1");
            });

            modelBuilder.Entity<Notification>(entity =>
            {
                entity.ToTable("notification");

                entity.HasIndex(e => e.ReciverId, "reciver_id");

                entity.HasIndex(e => e.SenderId, "sender_id");

                entity.Property(e => e.NotificationId)
                    .HasColumnType("int(11)")
                    .HasColumnName("notification_id");

                entity.Property(e => e.Content)
                    .HasMaxLength(50)
                    .HasColumnName("content");

                entity.Property(e => e.ItemId)
                    .HasColumnType("int(11)")
                    .HasColumnName("item_id");

                entity.Property(e => e.Link)
                    .HasMaxLength(100)
                    .HasColumnName("link");

                entity.Property(e => e.ReciverId)
                    .HasColumnType("int(11)")
                    .HasColumnName("reciver_id");

                entity.Property(e => e.Seen).HasColumnName("seen");

                entity.Property(e => e.SenderId)
                    .HasColumnType("int(11)")
                    .HasColumnName("sender_id");

                entity.Property(e => e.SentAt)
                    .HasColumnType("datetime")
                    .HasColumnName("sent_at");

                entity.Property(e => e.Type)
                    .HasMaxLength(50)
                    .HasColumnName("type");

                entity.HasOne(d => d.Reciver)
                    .WithMany(p => p.NotificationRecivers)
                    .HasForeignKey(d => d.ReciverId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("notification_ibfk_2");

                entity.HasOne(d => d.Sender)
                    .WithMany(p => p.NotificationSenders)
                    .HasForeignKey(d => d.SenderId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("notification_ibfk_1");
            });

            modelBuilder.Entity<Product>(entity =>
            {
                entity.ToTable("product");

                entity.HasIndex(e => e.VendorId, "vendor_id");

                entity.Property(e => e.ProductId)
                    .HasColumnType("int(11)")
                    .HasColumnName("product_id");

                entity.Property(e => e.Category)
                    .HasMaxLength(50)
                    .HasColumnName("category");

                entity.Property(e => e.CreatedAt)
                    .HasColumnType("datetime")
                    .HasColumnName("created_at");

                entity.Property(e => e.Delivery)
                    .HasMaxLength(50)
                    .HasColumnName("delivery");

                entity.Property(e => e.Description)
                    .HasColumnType("text")
                    .HasColumnName("description");

                entity.Property(e => e.Discount)
                    .HasColumnType("int(11)")
                    .HasColumnName("discount");

                entity.Property(e => e.Inventory)
                    .HasColumnType("int(11)")
                    .HasColumnName("inventory");

                entity.Property(e => e.IsPublished).HasColumnName("is_published");

                entity.Property(e => e.IsRemoved).HasColumnName("is_removed");

                entity.Property(e => e.LastUpdatedAt)
                    .HasColumnType("datetime")
                    .HasColumnName("last_updated_at");

                entity.Property(e => e.Name)
                    .HasMaxLength(50)
                    .HasColumnName("name");

                entity.Property(e => e.Price)
                    .HasColumnType("int(11)")
                    .HasColumnName("price");

                entity.Property(e => e.PublishedAt)
                    .HasColumnType("datetime")
                    .HasColumnName("published_at");

                entity.Property(e => e.Rating).HasColumnName("rating");

                entity.Property(e => e.VendorId)
                    .HasColumnType("int(11)")
                    .HasColumnName("vendor_id");

                entity.HasOne(d => d.Vendor)
                    .WithMany(p => p.Products)
                    .HasForeignKey(d => d.VendorId)
                    .HasConstraintName("product_ibfk_1");
            });

            modelBuilder.Entity<ProductMaterial>(entity =>
            {
                entity.ToTable("product_material");

                entity.HasIndex(e => e.MaterialId, "material_id");

                entity.HasIndex(e => e.ProductId, "product_id");

                entity.Property(e => e.ProductMaterialId)
                    .HasColumnType("int(11)")
                    .HasColumnName("product_material_id");

                entity.Property(e => e.MaterialId)
                    .HasColumnType("int(11)")
                    .HasColumnName("material_id");

                entity.Property(e => e.ProductId)
                    .HasColumnType("int(11)")
                    .HasColumnName("product_id");

                entity.HasOne(d => d.Material)
                    .WithMany(p => p.ProductMaterials)
                    .HasForeignKey(d => d.MaterialId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("product_material_ibfk_2");

                entity.HasOne(d => d.Product)
                    .WithMany(p => p.ProductMaterials)
                    .HasForeignKey(d => d.ProductId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("product_material_ibfk_1");
            });

            modelBuilder.Entity<ProductPicture>(entity =>
            {
                entity.ToTable("product_picture");

                entity.HasIndex(e => e.ProductId, "product_id");

                entity.Property(e => e.ProductPictureId)
                    .HasColumnType("int(11)")
                    .HasColumnName("product_picture_id");

                entity.Property(e => e.IsThumbnail).HasColumnName("is_thumbnail");

                entity.Property(e => e.ProductId)
                    .HasColumnType("int(11)")
                    .HasColumnName("product_id");

                entity.Property(e => e.ResourceLink)
                    .HasMaxLength(100)
                    .HasColumnName("resource_link");

                entity.Property(e => e.ResourceName)
                    .HasMaxLength(50)
                    .HasColumnName("resource_name");

                entity.HasOne(d => d.Product)
                    .WithMany(p => p.ProductPictures)
                    .HasForeignKey(d => d.ProductId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("product_picture_ibfk_1");
            });

            modelBuilder.Entity<ProductTag>(entity =>
            {
                entity.ToTable("product_tag");

                entity.HasIndex(e => e.ProductId, "product_id");

                entity.HasIndex(e => e.TagId, "tag_id");

                entity.Property(e => e.ProductTagId)
                    .HasColumnType("int(11)")
                    .HasColumnName("product_tag_id");

                entity.Property(e => e.ProductId)
                    .HasColumnType("int(11)")
                    .HasColumnName("product_id");

                entity.Property(e => e.TagId)
                    .HasColumnType("int(11)")
                    .HasColumnName("tag_id");

                entity.HasOne(d => d.Product)
                    .WithMany(p => p.ProductTags)
                    .HasForeignKey(d => d.ProductId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("product_tag_ibfk_1");

                entity.HasOne(d => d.Tag)
                    .WithMany(p => p.ProductTags)
                    .HasForeignKey(d => d.TagId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("product_tag_ibfk_2");
            });

            modelBuilder.Entity<Region>(entity =>
            {
                entity.ToTable("region");

                entity.Property(e => e.RegionId)
                    .HasColumnType("int(11)")
                    .ValueGeneratedNever()
                    .HasColumnName("region_id");

                entity.Property(e => e.RegionName)
                    .IsRequired()
                    .HasMaxLength(50)
                    .HasColumnName("region_name");
            });

            modelBuilder.Entity<Review>(entity =>
            {
                entity.ToTable("review");

                entity.HasIndex(e => e.MemberId, "member_id");

                entity.HasIndex(e => e.ProductId, "product_id");

                entity.Property(e => e.ReviewId)
                    .HasColumnType("int(11)")
                    .HasColumnName("review_id");

                entity.Property(e => e.Content)
                    .HasColumnType("text")
                    .HasColumnName("content");

                entity.Property(e => e.MemberId)
                    .HasColumnType("int(11)")
                    .HasColumnName("member_id");

                entity.Property(e => e.Points)
                    .HasColumnType("int(11)")
                    .HasColumnName("points");

                entity.Property(e => e.ProductId)
                    .HasColumnType("int(11)")
                    .HasColumnName("product_id");

                entity.Property(e => e.PublishedAt)
                    .HasColumnType("datetime")
                    .HasColumnName("published_at");

                entity.Property(e => e.Rating)
                    .HasColumnType("int(11)")
                    .HasColumnName("rating");

                entity.Property(e => e.Title)
                    .HasMaxLength(50)
                    .HasColumnName("title");

                entity.HasOne(d => d.Member)
                    .WithMany(p => p.Reviews)
                    .HasForeignKey(d => d.MemberId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("review_ibfk_2");

                entity.HasOne(d => d.Product)
                    .WithMany(p => p.Reviews)
                    .HasForeignKey(d => d.ProductId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("review_ibfk_1");
            });

            modelBuilder.Entity<ReviewVote>(entity =>
            {
                entity.ToTable("review_vote");

                entity.HasIndex(e => e.MemberId, "member_id");

                entity.HasIndex(e => e.ProductId, "product_id");

                entity.HasIndex(e => e.ReviewId, "review_id");

                entity.Property(e => e.ReviewVoteId)
                    .HasColumnType("int(11)")
                    .HasColumnName("review_vote_id");

                entity.Property(e => e.MemberId)
                    .HasColumnType("int(11)")
                    .HasColumnName("member_id");

                entity.Property(e => e.ProductId)
                    .HasColumnType("int(11)")
                    .HasColumnName("product_id");

                entity.Property(e => e.ReviewId)
                    .HasColumnType("int(11)")
                    .HasColumnName("review_id");

                entity.Property(e => e.Vote)
                    .HasMaxLength(10)
                    .HasColumnName("vote");

                entity.Property(e => e.VotedAt)
                    .HasColumnType("datetime")
                    .HasColumnName("voted_at");

                entity.HasOne(d => d.Member)
                    .WithMany(p => p.ReviewVotes)
                    .HasForeignKey(d => d.MemberId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("review_vote_ibfk_3");

                entity.HasOne(d => d.Product)
                    .WithMany(p => p.ReviewVotes)
                    .HasForeignKey(d => d.ProductId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("review_vote_ibfk_1");

                entity.HasOne(d => d.Review)
                    .WithMany(p => p.ReviewVotes)
                    .HasForeignKey(d => d.ReviewId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("review_vote_ibfk_2");
            });

            modelBuilder.Entity<Session>(entity =>
            {
                entity.ToTable("session");

                entity.HasIndex(e => e.MemberId, "session_ibfk_1");

                entity.Property(e => e.SessionId)
                    .HasColumnType("int(11)")
                    .HasColumnName("session_id");

                entity.Property(e => e.Jwt)
                    .IsRequired()
                    .HasMaxLength(1000)
                    .HasColumnName("jwt");

                entity.Property(e => e.LoggedInAt)
                    .HasColumnType("datetime")
                    .HasColumnName("logged_in_at");

                entity.Property(e => e.MemberId)
                    .HasColumnType("int(11)")
                    .HasColumnName("member_id");

                entity.HasOne(d => d.Member)
                    .WithMany(p => p.Sessions)
                    .HasForeignKey(d => d.MemberId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("session_ibfk_1");
            });

            modelBuilder.Entity<ShippingAddress>(entity =>
            {
                entity.ToTable("shipping_address");

                entity.HasIndex(e => e.MemberId, "member_id");

                entity.Property(e => e.ShippingAddressId)
                    .HasColumnType("int(11)")
                    .HasColumnName("shipping_address_id");

                entity.Property(e => e.City)
                    .HasMaxLength(50)
                    .HasColumnName("city");

                entity.Property(e => e.Country)
                    .HasMaxLength(50)
                    .HasColumnName("country");

                entity.Property(e => e.Email)
                    .IsRequired()
                    .HasMaxLength(320)
                    .HasColumnName("email");

                entity.Property(e => e.FirstName)
                    .HasMaxLength(50)
                    .HasColumnName("first_name");

                entity.Property(e => e.LastName)
                    .HasMaxLength(50)
                    .HasColumnName("last_name");

                entity.Property(e => e.MemberId)
                    .HasColumnType("int(11)")
                    .HasColumnName("member_id");

                entity.Property(e => e.Name)
                    .HasMaxLength(50)
                    .HasColumnName("name");

                entity.Property(e => e.Phone)
                    .HasMaxLength(20)
                    .HasColumnName("phone");

                entity.Property(e => e.PostalCode)
                    .HasMaxLength(4)
                    .HasColumnName("postal_code");

                entity.Property(e => e.Region)
                    .HasMaxLength(50)
                    .HasColumnName("region");

                entity.Property(e => e.StreetAdress)
                    .HasMaxLength(50)
                    .HasColumnName("street_adress");

                entity.HasOne(d => d.Member)
                    .WithMany(p => p.ShippingAddresses)
                    .HasForeignKey(d => d.MemberId)
                    .HasConstraintName("shipping_address_ibfk_1");
            });

            modelBuilder.Entity<Tag>(entity =>
            {
                entity.ToTable("tag");

                entity.Property(e => e.TagId)
                    .HasColumnType("int(11)")
                    .HasColumnName("tag_id");

                entity.Property(e => e.TagName)
                    .HasMaxLength(50)
                    .HasColumnName("tag_name");
            });

            modelBuilder.Entity<VendorDetail>(entity =>
            {
                entity.ToTable("vendor_detail");

                entity.HasIndex(e => e.MemberId, "member_id");

                entity.Property(e => e.VendorDetailId)
                    .HasColumnType("int(11)")
                    .HasColumnName("vendor_detail_id");

                entity.Property(e => e.CompanyName)
                    .HasMaxLength(50)
                    .HasColumnName("company_name");

                entity.Property(e => e.MemberId)
                    .HasColumnType("int(11)")
                    .HasColumnName("member_id");

                entity.Property(e => e.SiteLocation)
                    .HasMaxLength(50)
                    .HasColumnName("site_location");

                entity.Property(e => e.TakesCustomOrders).HasColumnName("takes_custom_orders");

                entity.Property(e => e.Website)
                    .HasMaxLength(50)
                    .HasColumnName("website");

                entity.HasOne(d => d.Member)
                    .WithMany(p => p.VendorDetails)
                    .HasForeignKey(d => d.MemberId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("vendor_detail_ibfk_1");
            });

            modelBuilder.Entity<WishList>(entity =>
            {
                entity.ToTable("wish_list");

                entity.HasIndex(e => e.MemberId, "member_id");

                entity.HasIndex(e => e.ProductId, "product_id");

                entity.Property(e => e.WishListId)
                    .HasColumnType("int(11)")
                    .HasColumnName("wish_list_id");

                entity.Property(e => e.AddedAt)
                    .HasColumnType("datetime")
                    .HasColumnName("added_at");

                entity.Property(e => e.MemberId)
                    .HasColumnType("int(11)")
                    .HasColumnName("member_id");

                entity.Property(e => e.ProductId)
                    .HasColumnType("int(11)")
                    .HasColumnName("product_id");

                entity.HasOne(d => d.Member)
                    .WithMany(p => p.WishLists)
                    .HasForeignKey(d => d.MemberId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("wish_list_ibfk_2");

                entity.HasOne(d => d.Product)
                    .WithMany(p => p.WishLists)
                    .HasForeignKey(d => d.ProductId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("wish_list_ibfk_1");
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
