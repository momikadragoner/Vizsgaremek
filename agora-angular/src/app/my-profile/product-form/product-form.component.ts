import { Component, OnInit, ɵCompiler_compileModuleAndAllComponentsSync__POST_R3__ } from '@angular/core';
import { Product, tags, ProductShort, categories, ProductService } from '../../services/product.service';
import { FormGroup, FormArray, FormBuilder, Validators, ValidatorFn, AbstractControl, ValidationErrors } from '@angular/forms';
import { faTruck, faBoxes, IconPrefix, faTree, faHandPaper, faBalanceScale, faExclamationCircle, faGem, faBoxOpen, faLeaf, faSeedling, faAppleAlt, faCarrot, faCheese, faTrash, faBreadSlice, faGlassMartiniAlt, faPalette, faTshirt, faInfoCircle, faSpinner } from '@fortawesome/free-solid-svg-icons';
import { FaIconLibrary } from '@fortawesome/angular-fontawesome';
import { asapScheduler, fromEventPattern } from 'rxjs';
import { JsonPipe } from '@angular/common';
import { ThrowStmt } from '@angular/compiler';
import { ActivatedRoute } from '@angular/router';
import { animate, style, transition, trigger } from '@angular/animations';
import { AuthService } from 'src/app/account-forms/services/auth.service';
import { PictureService } from 'src/app/services/picture.service';

@Component({
  selector: 'app-product-form',
  templateUrl: './product-form.component.html',
  styleUrls: ['./product-form.component.scss'],
  animations: [
    trigger('visibilityChange', [
      transition(':leave', [
        style({ opacity: 1 }),
        animate('0.2s',
          style({ opacity: 0, }))
      ]),
      transition(':enter', [
        style({ opacity: 0 }),
        animate('0.2s',
          style({ opacity: 1, }))
      ])
    ])
  ]
})
export class ProductFormComponent implements OnInit {

  iconPrefix: IconPrefix = 'fas';
  tagsList = tags;
  categories = categories;
  currentUser() {
    return this.authService.getUserDetails()[0];
  }

  faTruck = faTruck;
  faBoxes = faBoxes;
  faTrash = faTrash;
  faInfoCircle = faInfoCircle;
  faSpinner = faSpinner;

  discountAvailable = false;
  toolTipOpen: boolean[] = [];
  editingProduct?: Product;
  params: any;

  tagOpen: boolean[] = [];
  tagsShown: string[] = [];
  pictureLinks: string[] = [''];
  resourcePrefix = "http://localhost:3080/product_pictures/"
  modalOpen = false;
  uploadOpen = false;
  thumbnailIndex = "0";
  success?: boolean = undefined;
  message: string = 'Betöltés...';

  constructor(
    private fb: FormBuilder,
    private productService: ProductService,
    library: FaIconLibrary,
    activatedRoute: ActivatedRoute,
    private authService: AuthService,
    private pictureService: PictureService
  ) {
    library.addIcons(faHandPaper, faTree, faBalanceScale, faExclamationCircle, faGem, faBoxOpen, faLeaf, faSeedling, faAppleAlt, faCarrot, faCheese, faCarrot, faAppleAlt, faBreadSlice, faGlassMartiniAlt, faPalette, faTshirt);
    activatedRoute.queryParams.subscribe(param => this.params = { ...param['keys'], ...param });
    if (this.params.edit == 'true') {
      let id = Number(this.params.id);
      let form = this.productForm.value;
      let product: Product = { productId: 0, name: '', sellerFirstName: '', sellerLastName: '', price: -1, inventory: -1, delivery: '', category: '', tags: [], materials: [], imgUrl: [], description: '', isPublic: true, rating: -1, reviews: [] };;
      productService.getProduct(id)
        .subscribe({
          next: (data: Product) => {
            product = { ...data }
            form.name = product.name;
            form.price = product.price;
            form.discount = product.discount;
            form.inventory = product.inventory;
            form.delivery = product.delivery;
            form.category = product.category;
            form.description = product.description;
            this.editingProduct = product;
            this.productForm.setValue(form);
            product.tags.forEach(tag => {
              this.tags.push(this.fb.control(tag));
            })
            product.materials.forEach(material => {
              this.materials.push(this.fb.control(material));
            })
            this.inputChange();
          },
          error: error => console.log(error)
        });
    }
  }

  productForm = this.fb.group({
    name: ['', Validators.required],
    price: [null, [Validators.required, Validators.min(0)]],
    discount: [null, [Validators.max(99), Validators.min(1)]],
    inventory: [null],
    delivery: ['', Validators.required],
    category: ['', Validators.required],
    tags: this.fb.array([
    ]),
    materials: this.fb.array([
    ]),
    description: ['']
  });

  pictureForm = this.fb.group({
    pictures: [null],
  });

  newProduct = new ProductShort(0, this.productForm.value.name, '', '',
    this.productForm.value.price, this.productForm.value.imgUrl, undefined, undefined, this.productForm.value.discount
  );

  addTag() {
    this.tags.push(this.fb.control(''));
  }

  removeTag(id: any, $event: any) {
    $event.preventDefault();
    this.tags.removeAt(id);
  }

  addMaterial() {
    this.materials.push(this.fb.control(''));
  }

  removeMaterial(id: any, $event: any) {
    $event.preventDefault();
    this.materials.removeAt(id);
  }

  get tags() {
    return this.productForm.get('tags') as FormArray;
  }

  get materials() {
    return this.productForm.get('materials') as FormArray;
  }

  inputChange() {
    this.newProduct = new ProductShort(0, this.productForm.value.name, this.currentUser().first_name, this.currentUser().last_name,
      this.productForm.value.price, this.pictureLinks[0], undefined, undefined, this.productForm.value.discount
    );
  }

  getMaterials() {
    let materialLabel: string = "";
    this.productForm.value.materials.forEach((material: string) => {
      materialLabel += material;
      if (this.productForm.value.materials[this.productForm.value.materials.length - 1] != material) materialLabel += ", ";
    });
    return materialLabel;
  }

  discountChange() {
    this.discountAvailable = !this.discountAvailable;
    let update = this.productForm.value;
    update.discount = null;
    this.productForm.setValue(update);
  }

  tagOptions: string[] = [
    "Környezetbarát",
    "Kézzel készült",
    "Etikusan beszerzett alapanyagok",
    "Fenntartható",
    "Csomagolás mentes",
    "Vegetáriánus",
    "Vegán",
    "Bio"
  ];

  searchTag(id: number) {
    if (this.productForm.value.tags[id] == "") this.tagsShown = [...this.tagOptions];
    let result: string[] = [];
    this.tagOptions.forEach((option) => {
      let regex = new RegExp(this.productForm.value.tags[id].trim(), "i");
      if (option.match(regex)) {
        result.push(option);
      }
    })
    this.tagsShown = result;
  }

  autoFillTag(id: number, option: number) {
    let update = this.productForm.value;
    update.tags[id] = this.tagsShown[option];
    this.productForm.setValue(update);
    this.onTagFocusChange(id);
  }

  onTagFocusChange(id: number) {
    this.tagOpen[id] = !this.tagOpen[id];
  }

  deliveryChange() {
    if (this.productForm.value.delivery == "Megrendelésre készül") {
      let update = this.productForm.value;
      update.inventory = null;
      this.productForm.setValue(update);
    }
  }

  loadProduct(isPublic: boolean): Product {
    let form = this.productForm.value;
    let newProduct: Product =
    {
      productId: 0,
      name: form.name,
      price: form.price,
      discount: form.discount,
      inventory: form.inventory,
      delivery: form.delivery,
      category: form.category,
      sellerFirstName: this.currentUser().first_name,
      sellerLastName: this.currentUser().last_name,
      sellerId: this.currentUser().member_id,
      materials: form.materials,
      tags: form.tags,
      imgUrl: this.pictureLinks,
      description: form.description,
      isPublic: isPublic,
      publishedAt: (this.editingProduct ? this.editingProduct.publishedAt : undefined),
      reviews: []
    }
    if (this.editingProduct?.isPublic != newProduct.isPublic) {
      newProduct.publishedAt = new Date();
    }
    if (newProduct.imgUrl[0] == '') {
      newProduct.imgUrl[0] = 'assets/default_assets/def-prod.png'
    }
    console.log(newProduct);
    return newProduct;
  }

  postProduct(isPublic: boolean) {
    let newProduct = this.loadProduct(isPublic);
    this.productService
      .addProduct(newProduct)
      .subscribe({
        next: data => { this.message = "Termék sikeresen hozzáadva!"; this.success = true },
        error: error => { this.message = error; this.success = false }
      });
  }

  putProduct(isPublic: boolean) {
    let updatedProduct = this.loadProduct(isPublic);
    this.productService
      .updateProduct(updatedProduct, this.params.id)
      .subscribe({
        next: data => { this.message = "Termék sikeresen frissítve!"; this.success = true },
        error: error => { this.message = error; this.success = false }
      });
  }

  onSubmit() {
    this.modalOpen = true;
    this.postProduct(true);
  }

  saveProduct() {
    if (!this.productForm.valid) return;
    this.postProduct(false);
    this.modalOpen = true;
  }

  saveProductChange() {
    if (!this.productForm.valid) return;
    this.putProduct(false);
    this.modalOpen = true;
  }

  publishProductChange() {
    if (!this.productForm.valid) return;
    this.putProduct(true);
    this.modalOpen = true;
  }

  pictureSelected($event: any) {
    let formData: FormData = new FormData();
    console.log($event.target.files);
    formData.append('pictures', $event.target.files[0]);
    if ($event.target.files[1]) {
      formData.append('pictures', $event.target.files[1]);
    }
    if ($event.target.files[2]) {
      formData.append('pictures', $event.target.files[2]);
    }
    this.pictureService.addPicture(formData).subscribe({
      next: (res) => {
        let data:string[]= res.toString().split(',');
        this.pictureLinks = [];
        data.forEach(link => {
          this.pictureLinks.push(this.resourcePrefix + link);
        })

      },
      error: (err) => {
        console.log(err);
      }
    });
  }

  onUpload() {
    let selected:string = this.pictureLinks[Number(this.thumbnailIndex)];
    this.newProduct.imgUrl = selected;
    let tmp:string = this.pictureLinks[0];
    this.pictureLinks[0] = selected;
    this.pictureLinks[Number(this.thumbnailIndex)] = tmp;
    this.uploadOpen = false;
  }

  ngOnInit(): void {
  }

}
