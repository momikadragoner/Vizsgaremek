using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class Review
    {
        public Review()
        {
            ReviewVotes = new HashSet<ReviewVote>();
        }

        public int ReviewId { get; set; }
        public int ProductId { get; set; }
        public int MemberId { get; set; }
        public int? Rating { get; set; }
        public int? Points { get; set; }
        public string Title { get; set; }
        public string Content { get; set; }
        public DateTime? PublishedAt { get; set; }

        public virtual Member Member { get; set; }
        public virtual Product Product { get; set; }
        public virtual ICollection<ReviewVote> ReviewVotes { get; set; }
    }
}
