import { Component, OnInit, ViewChild } from '@angular/core';
import { Router, ActivatedRoute, ParamMap, NavigationStart, NavigationEnd, NavigationError } from '@angular/router';
import { faHandPaper, faEdit, faBalanceScale, faTree, faEnvelope, faShoppingCart, faHeart, faTruck, faGem, faBoxes, faStar, IconPrefix, faSpinner, IconName, faChevronLeft, faChevronRight, faExclamationCircle, faBoxOpen, faLeaf, faSeedling, faAppleAlt, faCarrot, faCheese, faBreadSlice, faGlassMartiniAlt, faPalette, faTshirt, faFolderOpen } from '@fortawesome/free-solid-svg-icons';
// import { faStar } from '@fortawesome/free-regular-svg-icons'
import { Icon, library } from '@fortawesome/fontawesome-svg-core';
import { Form } from '@angular/forms';
//import { productDetailed, productListShort, Product } from "../model/product";
import { User as u, seller } from "../services/user.service";
import { FaIconLibrary } from '@fortawesome/angular-fontawesome';
import { HttpClient } from '@angular/common/http';
import { ProductService, Product, ProductShort, ratingToArray } from '../services/product.service';
import { UserService, UserShort as User } from '../services/user.service';
import { asapScheduler } from 'rxjs';
import { Auth } from '../services/auth';
import { WishListService } from '../services/wishlist.service';
import { CartService } from '../services/cart.service';
import { animate, style, transition, trigger } from '@angular/animations';
import { ReviewService, Review } from '../services/review.service';
import { FollowService } from '../services/follow.service';

@Component({
  selector: 'app-product-detail',
  templateUrl: './product-detail.component.html',
  styleUrls: ['./product-detail.component.scss']
})
export class ProductDetailComponent implements OnInit {

  iconPrefix: IconPrefix = 'fas';
  toCartIcon: IconName = 'shopping-cart';
  toCartSpin: boolean = false;
  toWishListIcon: IconName = 'heart';
  toWishListSpin: boolean = false;
  faHandPaper = faHandPaper;
  faBalanceScale = faBalanceScale;
  faTree = faTree;
  faEnvelope = faEnvelope;
  faTruck = faTruck;
  faGem = faGem;
  faBoxes = faBoxes;
  faStar = faStar;
  faChevronRight = faChevronRight;
  faChevronLeft = faChevronLeft;
  faEdit = faEdit;
  faFolderOpen = faFolderOpen;

  review: Review = new Review();
  reviews: Review[] = [new Review()];
  product: Product = { productId: 0, name: '', sellerFirstName: '', sellerLastName: '', price: -1, inventory: -1, delivery: '', category: '', tags: [], materials: [], imgUrl: [], description: '', isPublic: true, rating: -1, reviews: this.reviews };
  productList: ProductShort[] = [{ productId: 0, name: "", sellerFirstName: "", sellerLastName: "", price: -1, imgUrl: "" }];
  seller: User = { userId: 0, firstName: '', lastName: '', about: "", profileImgUrl: "", companyName: undefined, takesCustomOrders: true };

  currentUser = Auth.currentUser;
  message: string = "";
  success?: boolean;
  id: any;
  currentRoute: string;
  error: any;

  constructor(
    library: FaIconLibrary,
    private productService: ProductService,
    private userService: UserService,
    private wishListService: WishListService,
    private cartService: CartService,
    private reviewService: ReviewService,
    private followService: FollowService,
    private route: ActivatedRoute,
    private router: Router,
  ) {
    library.addIcons(faHeart, faSpinner, faShoppingCart, faHandPaper, faTree, faBalanceScale, faExclamationCircle, faGem, faBoxOpen, faLeaf, faSeedling, faCarrot, faCheese, faAppleAlt, faBreadSlice, faGlassMartiniAlt, faPalette, faTshirt);
    this.currentRoute = "";
    this.router.events.subscribe((event: any) => {
      if (event instanceof NavigationStart) {
        // Show progress spinner or progress bar
        console.log('Route change detected');
      }

      if (event instanceof NavigationEnd) {
        // Hide progress spinner or progress bar
        this.currentRoute = event.url;
        this.ngOnInit();
        console.log(event);
      }

      if (event instanceof NavigationError) {
        // Hide progress spinner or progress bar

        // Present error to user
        console.log(event.error);
      }
    });
  }

  ngOnInit(): void {
    this.selectedImgIndex = 0;
    this.id = this.route.snapshot.paramMap.get('id');
    this.ShowProduct();
    this.ShowProductList();
  }

  ShowProduct() {
    this.productService.getProduct(this.id)
      .subscribe({
        next: (data: Product) => { this.product = { ...data }, this.ShowUser(this.product.sellerId) },
        error: error => this.error = error
      });
  }

  ShowReview(id: any) {
    this.reviewService.getReview(id)
      .subscribe({
        next: (data: Review) => this.review = { ...data },
        error: error => this.error = error
      });
  }

  ShowProductList() {
    this.productService.getAllProducts()
      .subscribe({
        next: (data: [ProductShort]) => this.productList = [...data],
        error: error => this.error = error
      });
  }

  ShowUser(id: any) {
    this.userService.getUserShort(id)
      .subscribe({
        next: (data: User) => this.seller = { ...data },
        error: error => this.error = error
      });
  }

  public modalVisible = false;
  public imgOpen = false;
  public newReviewOpen = false;
  public cartOpen = false;
  public selectedImg: string = this.product.imgUrl[0];
  public selectedImgIndex: number = 0;

  openModal(id: number[], $event: any) {
    $event.preventDefault();
    this.review = new Review();
    this.modalVisible = true;
    //console.log(id);
    this.ShowReview(id[0]);
  }

  selectImg(id: number, $event: any) {
    $event.preventDefault();
    this.selectedImg = this.product.imgUrl[id];
    this.selectedImgIndex = id;
  }

  fullScreenImg($event: any) {
    $event.preventDefault();
    this.imgOpen = true;
  }

  nextImg(next: number, $event: any) {
    $event.preventDefault();
    if (this.selectedImgIndex + next == this.product.imgUrl.length) {
      this.selectedImg = this.product.imgUrl[0];
      this.selectedImgIndex = 0;
    }
    else if (this.selectedImgIndex + next < 0) {
      this.selectedImg = this.product.imgUrl[this.product.imgUrl.length - 1];
      this.selectedImgIndex = this.product.imgUrl.length - 1;
    }
    else {
      this.selectedImg = this.product.imgUrl[this.selectedImgIndex + next];
      this.selectedImgIndex = this.selectedImgIndex + next;
    }
  }

  writeReview($event: any) {
    $event.preventDefault();
    this.newReviewOpen = true;
  }

  addToCart($event: any, id: number) {
    $event.preventDefault();
    this.toCartIcon = 'spinner';
    this.toCartSpin = true;
    this.cartService.postCart(id, this.currentUser.userId)
      .subscribe({
        next: data => {
          this.message = "Termék hozzáadva a kosárhoz";
          this.success = true;
          this.cartOpen = true;
          this.toCartIcon = 'shopping-cart';
          this.toCartSpin = false;
        },
        error: error => { this.message = "Kosárhoz adás sikertelen"; this.success = false }
      });
  }

  addToWishList($event: any, id: number) {
    $event.preventDefault();
    this.toWishListIcon = 'spinner';
    this.toWishListSpin = true;
    this.wishListService.postWishList(id, this.currentUser.userId)
      .subscribe({
        next: data => {
          this.toWishListIcon = 'heart';
          this.toWishListSpin = false;
        }
      });
  }

  closeNewReview() {
    this.newReviewOpen = false;
  }

  addReview(newReview:Review){
    this.product.reviews.splice(0,0,newReview);
  }

  follow($event: any, id: number) {
    $event.preventDefault();
    if (this.seller.iFollow == undefined) {
      return console.log("Nem vagy bejelentkezve");
    }
    if (this.seller.iFollow) {
      this.followService.deleteFollow(id).subscribe({
        next: data => {
          this.seller.iFollow = false;
        }
      })
    }
    else if(this.seller.iFollow == false){
      this.followService.postFollow(id).subscribe({
        next: data => {
          this.seller.iFollow = true;
        }
      });
    }
  }

  ratingToArray = ratingToArray;

}