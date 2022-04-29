using agora_test_data_generator.Models;
using System;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace agora_test_data_generator
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Agora Test Data Generator");
            Console.Write("Number of vendor accounts:");
            int vendorAmount = int.Parse(Console.ReadLine());
            Console.Write("Number of user accounts:");
            int userAmount = int.Parse(Console.ReadLine());
            Console.Write("Number of products:");
            int productAmount = int.Parse(Console.ReadLine());

            var context = new agorawebshopContext();

            List<Member> vendors = GenerateUser(vendorAmount, true);
            vendors.ForEach(x => context.Members.Add(x));
            context.SaveChanges();

            List<Member> users = GenerateUser(userAmount);
            users.ForEach(x => context.Members.Add(x));
            context.SaveChanges();

            List<Product> p = GenerateProduct(productAmount);
            p.ForEach(x => context.Products.Add(x));
            context.SaveChanges();

            var m = context.Members;
            foreach (var item in m)
            {
                AddFollowsAndWishes(item);
            }
            context.SaveChanges();

            Console.WriteLine("Data successfully generated!");

            List<Product> GenerateProduct(int amount)
            {
                List<Product> products = new List<Product>();
                string[] words = File.ReadAllLines("words.txt");
                Random r = new Random();
                for (int i = 0; i < amount; i++)
                {
                    Product product = new Product();

                    int price = r.Next(500, 25000);
                    if (!(price % 10 == 0))
                    {
                        price -= price % 10;
                    }
                    product.Price = price;
                    string description = "";
                    for (int j = 0; j < r.Next(8, 35); j++)
                    {
                        description += words[r.Next(0, words.Length)] + " ";
                    }
                    product.Description = description;
                    product.IsPublished = true;
                    product.PublishedAt = new DateTime(2022, r.Next(1, 5), r.Next(1, 29), r.Next(0, 24), r.Next(0, 60), r.Next(0, 60));
                    product.CreatedAt = product.PublishedAt;
                    product.Discount = null;

                    product.Delivery = r.Next(0, 3) == 0 ? "Megrendelésre készül" : "Azonnal szállítható";
                    if (product.Delivery == "Azonnal szállítható")
                    {
                        product.Inventory = r.Next(0, 25);
                    }
                    product.VendorId = r.Next(1, vendorAmount + 1);

                    List<int> tags = new List<int>();
                    for (int k = 0; k < r.Next(2, 4); k++)
                    {
                        ProductTag productTag = new ProductTag();
                        while (!(productTag.TagId > 0))
                        {
                            int tag = r.Next(1, 9);
                            if (!tags.Contains(tag))
                            {
                                productTag.TagId = tag;
                            }
                            tags.Add(tag);
                        }
                        product.ProductTags.Add(productTag);
                    }

                    if (i >= amount / 2)
                    {
                        string[] prefix = { "Lekváros", "Túrós", "Kakaós", "Pizzás", "Sós", "Karamellás", "Ízes", "Áfonyás" };
                        string[] type = { "Batyu", "Háromszög", "Csiga", "Croissant", "Kifli", "Kocka", "Levél" };
                        string name = prefix[r.Next(0, prefix.Length)] + " " + type[r.Next(0, type.Length)];
                        product.Name = name;
                        product.Category = "Pékáru";

                        for (int j = 0; j < 3; j++)
                        {
                            ProductMaterial productMaterial = new ProductMaterial();
                            productMaterial.MaterialId = r.Next(6, 13);
                            product.ProductMaterials.Add(productMaterial);
                        }

                        List<int> pictures = new List<int>();
                        for (int k = 0; k < r.Next(2, 4); k++)
                        {
                            ProductPicture productPicture = new ProductPicture();
                            while (productPicture.ResourceLink == null)
                            {
                                int picId = r.Next(1, 7);
                                if (!pictures.Contains(picId))
                                {
                                    productPicture.ResourceLink = "assets/product-pictures/pastry" + picId + ".jpg";
                                    productPicture.IsThumbnail = k == 0 ? true : false;
                                }
                                pictures.Add(picId);
                            }
                            product.ProductPictures.Add(productPicture);
                        }

                    }
                    if (i < amount / 2)
                    {
                        //sajt  
                        string[] prefix = { "Füstölt", "Finom", "Friss", "Házi", "" };
                        string[] type = { "Brie", "Parenyica", "Camambert", "Ementáli", "Edami", "Trapista", "Cheddar", "Parmezan" };
                        string name = prefix[r.Next(0, prefix.Length)] + " " + type[r.Next(0, type.Length)] + " Sajt";
                        product.Name = name;
                        product.Category = "Tejtermék";

                        ProductMaterial productMaterial = new ProductMaterial();
                        productMaterial.MaterialId = r.Next(0, 2) == 0 ? 6 : 7;
                        product.ProductMaterials.Add(productMaterial);

                        List<int> pictures = new List<int>();
                        for (int k = 0; k < r.Next(2, 4); k++)
                        {
                            ProductPicture productPicture = new ProductPicture();
                            while (productPicture.ResourceLink == null)
                            {
                                int picId = r.Next(1, 10);
                                if (!pictures.Contains(picId))
                                {
                                    productPicture.ResourceLink = "assets/product-pictures/cheese" + picId + ".jpg";
                                    productPicture.IsThumbnail = k == 0 ? true : false;
                                }
                                pictures.Add(picId);
                            }
                            product.ProductPictures.Add(productPicture);
                        }
                    }

                    //érékelések
                    for (int k = 0; k < r.Next(2, 8); k++)
                    {
                        Review review = new Review();
                        review.MemberId = r.Next(vendorAmount + 1, vendorAmount + userAmount);
                        string content = "";
                        string title = "";
                        for (int j = 0; j < r.Next(5, 20); j++)
                        {
                            content += words[r.Next(0, words.Length)] + " ";
                            if (j % 6 == 0)
                            {
                                title += words[r.Next(0, words.Length)] + " ";
                            }
                        }
                        review.Content = content;
                        review.Title = title;
                        review.Points = r.Next(0, 15);
                        review.Rating = r.Next(1, 6);
                        review.PublishedAt = product.PublishedAt;
                        product.Reviews.Add(review);
                    }
                    double avg = (double)product.Reviews.Average(x => x.Rating);
                    product.Rating = Math.Round(avg, 2);
                    products.Add(product);
                }
                return products;
            }

            List<Member> GenerateUser(int amount, bool isVendor = false)
            {
                string[] firstNames = File.ReadAllLines("firstName.txt");
                string[] lastNames = File.ReadAllLines("lastName.txt");
                string[] towns = File.ReadAllLines("telepulesek.txt");
                List<Member> users = new List<Member>();
                Random r = new Random();
                for (int i = 0; i < amount; i++)
                {
                    Member user = new Member();
                    user.FirstName = firstNames[r.Next(0, firstNames.Length)];
                    user.LastName = lastNames[r.Next(0, lastNames.Length)];
                    string[] letters = { "á", "é", "ú", "ő", "ó", "ü", "ö" };
                    string[] reLetters = { "a", "e", "u", "o", "o", "u", "o" };
                    string email = user.FirstName.ToLower() + user.LastName.ToLower() + r.Next(0, 1000) + "@mail.com";
                    for (int j = 0; j < 6; j++)
                    {
                        email = email.Replace(letters[j], reLetters[j]);
                    }
                    user.Email = email;
                    string phone = "+36 ";
                    phone += r.Next(1, 10) + "0 ";
                    for (int k = 0; k < 8; k++)
                    {
                        if (k == 3)
                        {
                            phone += " ";
                        }
                        else
                        {
                            phone += r.Next(1, 10);
                        }
                    }
                    user.Phone = phone;
                    user.IsVendor = isVendor;
                    user.IsAdmin = false;
                    user.Password = "827ccb0eea8a706c4c34a16891f84e7b";
                    user.RegisteredAt = new DateTime(2022, r.Next(1, 5), r.Next(1, 29), r.Next(0, 24), r.Next(0, 60), r.Next(0, 60));
                    if (isVendor)
                    {
                        VendorDetail vendorDetail = new VendorDetail();
                        vendorDetail.TakesCustomOrders = r.Next(0, 2) == 0 ? true : false;
                        vendorDetail.SiteLocation = towns[r.Next(0, towns.Length)];
                        if (r.Next(0, 3) == 0)
                        {
                            string[] companyPrefix = { "PeachTree", "PeaceOfMind", "GreenFarm", "LightPicture", "Express", "Protect" };
                            string[] companySufix = { "Csoport", "Holding", "Kft.", "Invest", "Group", "Zrt." };
                            string companyName = companyPrefix[r.Next(0, companyPrefix.Length)];
                            vendorDetail.CompanyName = companyName + " " + companySufix[r.Next(0, companySufix.Length)];
                            vendorDetail.Website = companyName.ToLower() + ".hu";
                        }
                        user.VendorDetails.Add(vendorDetail);
                    }
                    if (r.Next(0, 2) == 0)
                    {
                        user.ProfilePictureLink = "assets/def-pfp1.png";
                    }
                    else
                    {
                        user.ProfilePictureLink = "assets/def-pfp2.png";
                    }

                    switch (r.Next(0, 3))
                    {
                        case 0:
                            user.HeaderPictureLink = "assets/default_assets/def-bg.png";
                            break;
                        case 1:
                            user.HeaderPictureLink = "assets/default_assets/def-bg2.png";
                            break;
                        case 2:
                            user.HeaderPictureLink = "assets/default_assets/def-bg3.png";
                            break;
                    }

                    string[] words = File.ReadAllLines("words.txt");
                    string about = "";
                    Random q = new Random();
                    for (int j = 0; j < r.Next(8, 40); j++)
                    {
                        about += words[q.Next(0, words.Length)] + " ";
                    }
                    user.About = about.Remove(about.Length - 1, 1);
                    users.Add(user);
                }
                return users;
            }

            void AddFollowsAndWishes(Member user)
            {
                Random r = new Random();
                List<int> follows = new List<int>();
                for (int j = 0; j < r.Next(4, 11); j++)
                {
                    int follow = r.Next(1, vendorAmount + 1);
                    if (!follows.Contains(follow) && follow != user.MemberId)
                    {
                        FollowerRelation followerRelation = new FollowerRelation();
                        followerRelation.FollowingId = follow;
                        follows.Add(follow);
                        followerRelation.FollowerId = user.MemberId;
                        context.FollowerRelations.Add(followerRelation);
                    }
                }

                List<int> wishes = new List<int>();
                for (int j = 0; j < r.Next(0, 8); j++)
                {
                    int wish = r.Next(1, productAmount + 1);
                    if (!wishes.Contains(wish))
                    {
                        WishList wishList = new WishList();
                        wishList.ProductId = wish;
                        wishList.MemberId = user.MemberId;
                        wishes.Add(wish);
                        context.WishLists.Add(wishList);
                    }
                }
            }
        }
    }
}
