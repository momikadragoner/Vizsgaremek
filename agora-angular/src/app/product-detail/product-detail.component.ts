import { Component, OnInit, ViewChild } from '@angular/core';
import { Router, ActivatedRoute, ParamMap, NavigationStart, NavigationEnd, NavigationError } from '@angular/router';
import { faHandPaper, faEdit, faBalanceScale, faTree, faEnvelope, faShoppingCart, faHeart, faTruck, faGem, faBoxes, faStar, IconPrefix, IconName, faChevronLeft, faChevronRight, faExclamationCircle, faBoxOpen, faLeaf, faSeedling, faAppleAlt, faCarrot, faCheese, faBreadSlice, faGlassMartiniAlt, faPalette, faTshirt } from '@fortawesome/free-solid-svg-icons';
// import { faStar } from '@fortawesome/free-regular-svg-icons'
import { library } from '@fortawesome/fontawesome-svg-core';
import { Form } from '@angular/forms';
//import { productDetailed, productListShort, Product } from "../model/product";
import { User as u, seller } from "../services/user.service";
import { FaIconLibrary } from '@fortawesome/angular-fontawesome';
import { HttpClient } from '@angular/common/http';
import { ProductService, Product, Review, ProductShort, ratingToArray } from '../services/product.service';
import { UserService, UserShort as User } from '../services/user.service';
import { asapScheduler } from 'rxjs';



@Component({
  selector: 'app-product-detail',
  templateUrl: './product-detail.component.html',
  styleUrls: ['./product-detail.component.scss']
})
export class ProductDetailComponent implements OnInit {

  iconPrefix: IconPrefix = 'fas';
  faHandPaper = faHandPaper;
  faBalanceScale = faBalanceScale;
  faTree = faTree;
  faEnvelope = faEnvelope;
  faShoppingCart = faShoppingCart;
  faHeart = faHeart;
  faTruck = faTruck;
  faGem = faGem;
  faBoxes = faBoxes;
  faStar = faStar;
  faChevronRight = faChevronRight;
  faChevronLeft = faChevronLeft;
  faEdit = faEdit;

  product: Product = { productId: 0, name: '', sellerFirstName: '', sellerLastName: '', price: -1, inventory: -1, delivery: '', category: '', tags: [], materials: [], imgUrl: [], description: '', isPublic: true, rating: -1 };
  review: Review = { reviewId: 0, userId: 0, userLastName: "", userFirstName: "", title: "", content: "", rating: 0, points: 0, publishedAt: new Date() };
  productList: ProductShort[] = [{ productId: 0, name: "", sellerFirstName: "", sellerLastName: "", price: -1, imgUrl: "" }];
  seller: User = { userId: 0, firstName: '', lastName: '', about: "", profileImgUrl: "", companyName: undefined, takesCustomOrders: true };
  id: any;
  currentRoute: string;
  error: any;

  constructor(
    library: FaIconLibrary,
    private productService: ProductService,
    private userService: UserService,
    private route: ActivatedRoute,
    private router: Router
  ) {
    library.addIcons(faHandPaper, faTree, faBalanceScale, faExclamationCircle, faGem, faBoxOpen, faLeaf, faSeedling, faCarrot, faCheese, faAppleAlt, faBreadSlice, faGlassMartiniAlt, faPalette, faTshirt);
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
    //this.ShowUser(this.product.sellerId);
    // this.route.queryParams.subscribe(params => {
    //   this.id = params['id'];
    //   console.log(params['id'])
    // });
  }

  ShowProduct() {
    this.productService.getProduct(this.id)
      .subscribe((data: Product) => {this.product = { ... data}, this.ShowUser(this.product.sellerId)}, error => this.error = error);
    // console.log(this.product);
    // console.log(this.error);
  }

  ShowReview(id:any) {
    this.productService.getReview(id)
    .subscribe((data: Review) => this.review = { ... data}, error => this.error = error);
    console.log(this.review);
  }

  ShowProductList() {
    this.productService.getAllProducts()
      .subscribe((data: [ProductShort]) => this.productList = [...data], error => this.error = error);
  }

  ShowUser(id:any) {
    this.userService.getUserShort(id)
      .subscribe((data: User) => this.seller = { ...data }, error => this.error = error);
  }

  public modalVisible = false;
  public imgOpen = false;
  public newReviewOpen = false;
  public cartOpen = false;
  public selectedImg: string = this.product.imgUrl[0];
  public selectedImgIndex: number = 0;

  openModal(id: number[], $event: any) {
    $event.preventDefault();
    this.review = { reviewId: 0, userId: 0, userLastName: "", userFirstName: "", title: "", content: "", rating: -1, points: -1, publishedAt: new Date() };
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

  addToCart($event: any) {
    $event.preventDefault();
    this.cartOpen = true;
  }

  closeNewReview() {
    this.newReviewOpen = false;
  }

  ratingToArray = ratingToArray;

}
