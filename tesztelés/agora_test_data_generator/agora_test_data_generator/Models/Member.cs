using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class Member
    {
        public Member()
        {
            Carts = new HashSet<Cart>();
            FollowerRelationFollowers = new HashSet<FollowerRelation>();
            FollowerRelationFollowings = new HashSet<FollowerRelation>();
            MessageRecivers = new HashSet<Message>();
            MessageSenders = new HashSet<Message>();
            NotificationRecivers = new HashSet<Notification>();
            NotificationSenders = new HashSet<Notification>();
            Products = new HashSet<Product>();
            ReviewVotes = new HashSet<ReviewVote>();
            Reviews = new HashSet<Review>();
            Sessions = new HashSet<Session>();
            ShippingAddresses = new HashSet<ShippingAddress>();
            VendorDetails = new HashSet<VendorDetail>();
            WishLists = new HashSet<WishList>();
        }

        public int MemberId { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string Phone { get; set; }
        public string About { get; set; }
        public string ProfilePictureLink { get; set; }
        public string HeaderPictureLink { get; set; }
        public DateTime RegisteredAt { get; set; }
        public DateTime? LastLogin { get; set; }
        public bool IsVendor { get; set; }
        public bool IsAdmin { get; set; }

        public virtual ICollection<Cart> Carts { get; set; }
        public virtual ICollection<FollowerRelation> FollowerRelationFollowers { get; set; }
        public virtual ICollection<FollowerRelation> FollowerRelationFollowings { get; set; }
        public virtual ICollection<Message> MessageRecivers { get; set; }
        public virtual ICollection<Message> MessageSenders { get; set; }
        public virtual ICollection<Notification> NotificationRecivers { get; set; }
        public virtual ICollection<Notification> NotificationSenders { get; set; }
        public virtual ICollection<Product> Products { get; set; }
        public virtual ICollection<ReviewVote> ReviewVotes { get; set; }
        public virtual ICollection<Review> Reviews { get; set; }
        public virtual ICollection<Session> Sessions { get; set; }
        public virtual ICollection<ShippingAddress> ShippingAddresses { get; set; }
        public virtual ICollection<VendorDetail> VendorDetails { get; set; }
        public virtual ICollection<WishList> WishLists { get; set; }
    }
}
